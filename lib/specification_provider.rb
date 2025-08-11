require 'molinillo'
require_relative 'version'
require_relative 'requirement'
require_relative 'dependency'
require_relative 'specification'

class SpecificationProvider
  include Molinillo::SpecificationProvider

  def initialize(specifications = [])
    # パッケージレジストリ
    temp_specifications = {}
    specifications.each do |spec|
      temp_specifications[spec.name] ||= []
      temp_specifications[spec.name] << spec
      temp_specifications[spec.name].sort! { |a, b| b.version <=> a.version }
    end
    temp_specifications.each_value(&:freeze)
    @specifications = temp_specifications.freeze
  end

  # 依存関係の名前を返す
  # @param dependency [Dependency] 依存関係オブジェクト
  # @return [String] 依存関係の名前
  def name_for(dependency)
    dependency.name
  end

  # 指定された依存関係に対する利用可能な仕様を検索する
  # @param dependency [Dependency] 依存関係オブジェクト
  # @return [Array<Specification>] 利用可能な仕様の配列
  def search_for(dependency)
    name = dependency.name
    requirement = dependency.requirement
    
    available_specs = @specifications[name] || []
    
    # 要件を満たすバージョンをフィルタリング
    matching_specs = available_specs.select do |spec|
      requirement.satisfied_by?(spec.version)
    end
    
    # バージョンの降順でソート（新しいバージョンが優先）
    matching_specs.sort { |a, b| b.version <=> a.version }
  end

  # 指定された仕様の依存関係を返す
  # @param specification [Specification] 仕様オブジェクト
  # @return [Array<Dependency>] 依存関係の配列
  def dependencies_for(specification)
    specification.dependencies
  end

  # 要件が指定された仕様によって満たされるかチェックする
  # @param requirement [Dependency] 要件
  # @param activated [DependencyGraph] 依存関係グラフ
  # @param spec [Specification] 仕様（Molinillo 0.8.0では3番目の引数が実際の仕様、必須）
  # @return [Boolean] 要件が満たされるか
  def requirement_satisfied_by?(requirement, activated, spec)
    return false unless requirement.name == spec.name
    
    requirement.requirement.satisfied_by?(spec.version)
  end

  # 2つの依存関係が等しいかチェックする
  # @param dependencies [Array<Dependency>] 依存関係の配列1
  # @param other_dependencies [Array<Dependency>] 依存関係の配列2
  # @return [Boolean] 依存関係が等しいか
  def dependencies_equal?(dependencies, other_dependencies)
    return true if dependencies == other_dependencies
    return false if dependencies.nil? || other_dependencies.nil?
    return false if dependencies.size != other_dependencies.size
    
    # ソートして比較（順序を無視）
    sorted_deps = dependencies.sort_by { |dep|
      [dep.name, dep.requirement.operator, dep.requirement.version.major]
    }
    sorted_other_deps = other_dependencies.sort_by {
      |dep| [dep.name, dep.requirement.operator, dep.requirement.version.major]
    }
    
    sorted_deps == sorted_other_deps
  end

  # 依存関係をソートする（解決の効率化のため）
  # @param dependencies [Array<Dependency>] ソートする依存関係の配列
  # @param activated [Molinillo::DependencyGraph] アクティブ化されたグラフ
  # @param conflicts [Hash] 競合情報
  # @return [Array<Dependency>] ソートされた依存関係の配列
  def sort_dependencies(dependencies, activated, conflicts)
    # 依存関係解決の効率化のための優先順位付け：
    # 
    # 1. 競合がある依存関係を最優先で処理
    #    - 既に競合が発生している依存関係を早期に解決することで、
    #      バックトラッキングの回数を減らし、解決速度を向上させる
    #    - 例：AとBが同じライブラリの異なるバージョンを要求している場合
    # 
    # 2. より制限的な要件を持つ依存関係を優先
    #    - 制限の強い順：= > <,> > >=,<= 
    #    - 制限的な要件を先に満たすことで、後続の選択肢を効果的に絞り込める
    #    - 例：'= 6.1.0' を '>= 6.0' より先に処理することで、
    #      バージョン6.1.0が確定し、他の依存関係の解決が簡単になる
    # 
    # 3. パッケージ名のアルファベット順
    #    - 同じ優先度の依存関係に対して決定的な順序を提供
    #    - テスト結果の一貫性と予測可能性を保証
    dependencies.sort_by do |dependency|
      name = dependency.name
      has_conflict = conflicts.key?(name) ? 0 : 1
      restrictiveness = calculate_restrictiveness(dependency.requirement)
      
      [has_conflict, restrictiveness, name]
    end
  end

  # ロック用の依存関係ソース名を返す
  # @param dependency [Dependency] 依存関係
  # @return [String] ソース名
  def name_for_locking_dependency_source(dependency)
    dependency.name
  end

  # 明示的な依存関係ソース名を返す
  # @param dependency [Dependency] 依存関係
  # @return [String] ソース名
  def name_for_explicit_dependency_source(dependency)
    dependency.name
  end

  # 依存関係が見つからない場合に許可するか
  # @param dependency [Dependency] 依存関係
  # @return [Boolean] 見つからない場合を許可するか
  def allow_missing?(dependency)
    false  # 基本的には見つからない依存関係は許可しない
  end

  private

  # 要件の制限性を計算する（ソート用）
  # より制限的な要件ほど小さい値を返す
  # @param requirement [Requirement] 要件オブジェクト
  # @return [Integer] 制限性スコア
  def calculate_restrictiveness(requirement)
    case requirement.operator
    when '='
      0  # 最も制限的
    when '<'
      1
    when '>'
      1
    when '>='
      2
    when '<='
      2
    else
      3  # 最も制限が少ない
    end
  end
end
