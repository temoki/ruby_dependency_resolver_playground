# 依存パッケージを表すクラス
class Dependency
  attr_reader :name, :requirement

  # 初期化
  # @param name [String] 依存パッケージ名
  # @param requirement [Requirement] 依存パッケージの必要条件
  def initialize(name, requirement)
    @name = name
    @requirement = requirement
  end

  def to_s
    "#{name} (#{requirement})"
  end

  def ==(other)
    other.is_a?(Dependency) && name == other.name && requirement == other.requirement
  end

  def hash
    [name, requirement].hash
  end

  def eql?(other)
    self == other
  end

  # 指定されたSpecificationがこの依存関係を満たすかどうかを判断
  # @param spec [Specification] 判定対象のSpecification
  # @return [Boolean] 依存関係を満たす場合はtrue
  def satisfied_by?(spec)
    return false unless spec.is_a?(Specification)
    return false unless name == spec.name
    
    requirement.satisfied_by?(spec.version)
  end
end
