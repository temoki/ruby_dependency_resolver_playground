require_relative 'version_constraint'

# 依存関係を表現するクラス
class Dependency
  attr_reader :name, :version_constraint

  def initialize(name, version_constraint = nil)
    @name = name
    @version_constraint = normalize_version_constraint(version_constraint)
  end

  def to_s
    if version_constraint.nil?
      name.to_s
    else
      "#{name} (#{version_constraint})"
    end
  end

  def ==(other)
    other.is_a?(Dependency) && name == other.name && version_constraint == other.version_constraint
  end

  def hash
    [name, version_constraint].hash
  end

  def eql?(other)
    self == other
  end

  private

  def normalize_version_constraint(constraint)
    case constraint
    when nil
      nil
    when VersionConstraint
      constraint
    when String
      # 後方互換性のため文字列もサポート（非推奨）
      parse_string_constraint(constraint)
    else
      raise ArgumentError, "Version constraint must be nil, VersionConstraint, or String. Got #{constraint.class}"
    end
  end

  def parse_string_constraint(str)
    return nil if str.nil? || str.empty?
    
    case str
    when /^>= (.+)$/
      VersionConstraint.gte($1)
    when /^> (.+)$/
      VersionConstraint.gt($1)
    when /^<= (.+)$/
      VersionConstraint.lte($1)
    when /^< (.+)$/
      VersionConstraint.lt($1)
    when /^~> (.+)$/
      VersionConstraint.pessimistic($1)
    when /^= (.+)$/
      VersionConstraint.equal($1)
    else
      # 演算子なしの場合は等価とみなす
      VersionConstraint.equal(str)
    end
  end
end
