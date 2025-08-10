require 'molinillo'
require_relative 'package'

# 要件を表現するクラス
class Requirement
  attr_reader :name, :version_constraint

  def initialize(name, version_constraint = nil)
    @name = name
    @version_constraint = version_constraint
  end

  def satisfied_by?(package)
    return true if version_constraint.nil?
    
    # シンプルなバージョン比較（実際の実装ではより複雑）
    case version_constraint
    when /^>= (.+)$/
      Gem::Version.new(package.version) >= Gem::Version.new($1)
    when /^~> (.+)$/
      base_version = Gem::Version.new($1)
      pkg_version = Gem::Version.new(package.version)
      pkg_version >= base_version && pkg_version.release < base_version.bump
    when /^= (.+)$/, /^(.+)$/
      target = $1 || version_constraint
      package.version == target
    else
      package.version == version_constraint
    end
  rescue
    # Gem::Versionが使えない場合の簡単な文字列比較
    package.version == version_constraint
  end

  def to_s
    version_constraint ? "#{name} (#{version_constraint})" : name
  end
end

# Molinillo用のSpecificationProvider実装
class SimpleSpecificationProvider
  include Molinillo::SpecificationProvider

  def initialize(packages)
    @packages = packages
  end

  def search_for(dependency)
    dependency_name = name_for(dependency)
    results = @packages.select { |pkg| pkg.name == dependency_name }
    results
  end

  def name_for(dependency)
    case dependency
    when String
      dependency
    when Requirement
      dependency.name
    when Package
      dependency.name
    else
      dependency.to_s
    end
  end

  def name_for_explicit_dependency_source
    nil
  end

  def name_for_locking_dependency_source
    nil
  end

  def dependencies_for(package)
    return [] unless package.is_a?(Package)
    deps = package.dependencies.map { |dep| Requirement.new(dep[:name], dep[:version]) }
    deps
  end

  def requirement_satisfied_by?(requirement, activated, package)
    requirement.satisfied_by?(package)
  end

  def sort_dependencies(dependencies, activated, conflicts)
    dependencies.sort_by(&:name)
  end

  def allow_missing?(dependency)
    false
  end
end

# シンプルなUI実装
class SimpleUI
  include Molinillo::UI

  def output
    @output ||= []
  end

  def debug?
    false
  end

  def debug(depth = 0)
    # デバッグ出力は省略
  end

  def before_resolution
    puts "依存関係解決を開始します..."
  end

  def after_resolution
    puts "依存関係解決が完了しました。"
  end

  def indicate_progress
    print "."
  end
end

# サンプルパッケージデータの作成
def create_sample_packages
  [
    Package.new('rack', '2.0.0', []),
    Package.new('rack', '2.1.0', []),
    Package.new('rack', '3.0.0', []),
    
    Package.new('sinatra', '2.0.0', [
      { name: 'rack', version: '>= 2.0.0' }
    ]),
    Package.new('sinatra', '2.1.0', [
      { name: 'rack', version: '>= 2.1.0' }
    ]),
    
    Package.new('rails', '6.0.0', [
      { name: 'rack', version: '~> 2.0' }
    ]),
    Package.new('rails', '7.0.0', [
      { name: 'rack', version: '~> 2.1' }
    ]),
    
    # 競合を作るための追加パッケージ
    Package.new('legacy_app', '1.0.0', [
      { name: 'rack', version: '= 2.0.0' }  # 厳密にrack 2.0.0のみ
    ]),
    Package.new('modern_app', '1.0.0', [
      { name: 'rack', version: '= 3.0.0' }  # 厳密にrack 3.0.0のみ
    ])
  ]
end

# メイン実行部分
def main
  puts "=== Molinillo 依存関係解決サンプル ==="
  
  # パッケージデータの準備
  packages = create_sample_packages
  puts "\n利用可能なパッケージ:"
  packages.each { |pkg| puts "  #{pkg}" }
  
  # SpecificationProviderとUIの作成
  spec_provider = SimpleSpecificationProvider.new(packages)
  ui = SimpleUI.new
  
  # Resolverの作成
  resolver = Molinillo::Resolver.new(spec_provider, ui)
  
  # ケース1: 正常な解決
  puts "\n" + "="*50
  puts "ケース1: 正常な依存関係解決"
  puts "="*50
  
  requirements = [
    Requirement.new('sinatra', '2.0.0'),
  ]
  
  run_resolution(resolver, requirements)
  
  # ケース2: バージョン競合のケース
  puts "\n" + "="*50
  puts "ケース2: バージョン競合が発生するケース"
  puts "="*50
  
  # 互換性のない要件を設定
  conflicting_requirements = [
    Requirement.new('legacy_app', '1.0.0'),  # rack = 2.0.0が必要
    Requirement.new('modern_app', '1.0.0'),  # rack = 3.0.0が必要
  ]
  
  run_resolution(resolver, conflicting_requirements)
  
  # ケース3: 複数パッケージの同時解決
  puts "\n" + "="*50
  puts "ケース3: 複数パッケージの同時解決"
  puts "="*50
  
  multiple_requirements = [
    Requirement.new('sinatra', '>= 2.0.0'),
    Requirement.new('rails', '6.0.0'),
  ]
  
  run_resolution(resolver, multiple_requirements)
end

def run_resolution(resolver, requirements)
  puts "\n要求された依存関係:"
  requirements.each { |req| puts "  #{req}" }
  
  begin
    # 依存関係解決の実行
    puts "\n--- 解決プロセス ---"
    result = resolver.resolve(requirements)
    
    puts "\n--- 解決結果 ---"
    result.vertices.each do |name, vertex|
      next if vertex.payload.nil?
      puts "✅ #{name}: #{vertex.payload}"
    end
    
  rescue Molinillo::VersionConflict => e
    puts "\n❌ バージョン競合が発生しました:"
    puts e.message
    puts "\n競合の詳細:"
    e.conflicts.each do |name, conflict|
      puts "  #{name}:"
      conflict.requirements.each do |requirement|
        puts "    - #{requirement}"
      end
    end
    
  rescue => e
    puts "\n❌ エラーが発生しました: #{e.message}"
    puts e.backtrace.first(5)
  end
end

# スクリプトが直接実行された場合のみmainを呼び出す
if __FILE__ == $0
  main
end