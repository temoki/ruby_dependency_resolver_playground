require 'molinillo'
require_relative 'specification_provider'
require_relative 'resolver_ui'
require_relative 'specification'
require_relative 'dependency'
require_relative 'requirement'
require_relative 'version'

# サンプルの仕様を作成（正常に解決できるケース）
specifications = [
  Specification.new('gem_a', Version.new(1), []),
  Specification.new('gem_a', Version.new(2), []),
  Specification.new('gem_b', Version.new(1), [
    Dependency.new('gem_a', Requirement.new('>=', Version.new(1)))  # gem_a 1以上を要求
  ]),
  Specification.new('gem_c', Version.new(1), [
    Dependency.new('gem_a', Requirement.new('>=', Version.new(1))),  # gem_a 1以上を要求
    Dependency.new('gem_b', Requirement.new('>=', Version.new(1)))   # gem_b 1以上を要求
  ])
]

# SpecificationProviderとUIを初期化
provider = SpecificationProvider.new(specifications)
ui = ResolverUI.new(true)

# 解決したい依存関係を定義
requested_dependencies = [
  Dependency.new('gem_c', Requirement.new('>=', Version.new(1)))
]

# Resolverを作成して実行
resolver = Molinillo::Resolver.new(provider, ui)

begin
  result = resolver.resolve(requested_dependencies)
  
  # DependencyGraphから仕様を取得
  puts "🗒️ Results"
  if result.respond_to?(:vertices)
    result.vertices.each do |name, vertex|
      if vertex.payload
        puts "* #{vertex.payload}"
      end
    end
  else
    # フォールバック: 結果が他の形式の場合
    puts "* #{result}"
  end
rescue Molinillo::ResolverError => e
  puts "❌ 解決に失敗しました: #{e.message}"
end