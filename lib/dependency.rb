# 依存関係を表現するクラス
class Dependency
  attr_reader :name, :version_constraint

  def initialize(name, version_constraint = nil)
    @name = name
    @version_constraint = version_constraint
  end

  def to_s
    if version_constraint.nil? || version_constraint.empty?
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

  # ハッシュ形式から変換するためのクラスメソッド
  def self.from_hash(hash)
    new(hash[:name], hash[:version])
  end

  # ハッシュ形式に変換
  def to_hash
    { name: name, version: version_constraint }
  end
end
