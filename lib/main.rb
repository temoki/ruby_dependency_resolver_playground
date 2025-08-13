require 'molinillo'
require_relative 'specification_provider'
require_relative 'resolver_ui'
require_relative 'specification'
require_relative 'dependency'
require_relative 'requirement'
require_relative 'version'

def main(specifications)
  # SpecificationProviderとUIを初期化
  provider = SpecificationProvider.new(specifications)
  ui = ResolverUI.new(true)

  # 解決したい依存関係を定義
  requested_dependencies = [
    Dependency.new('http', Requirement.new('>=', Version.new(3))),
    Dependency.new('json', Requirement.new('>=', Version.new(2))),
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
end

specifications1 = [
  Specification.new('logger', Version.new(1), []),
  Specification.new('logger', Version.new(2), []),
  Specification.new('logger', Version.new(3), []),
  Specification.new('http', Version.new(1), [
    Dependency.new('logger', Requirement.new('>=', Version.new(1)))
  ]),
  Specification.new('http', Version.new(2), [
    Dependency.new('logger', Requirement.new('>=', Version.new(2)))
  ]),
  Specification.new('http', Version.new(3), [
    Dependency.new('logger', Requirement.new('>=', Version.new(3)))
  ]),
  Specification.new('json', Version.new(1), [
    Dependency.new('logger', Requirement.new('>=', Version.new(2)))
  ]),
  Specification.new('json', Version.new(2), [
    Dependency.new('logger', Requirement.new('>=', Version.new(2)))
  ]),
]

main(specifications1)
