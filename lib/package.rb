# パッケージを表現するクラス
class Package
  attr_reader :name, :version, :dependencies

  def initialize(name, version, dependencies = [])
    @name = name
    @version = version
    @dependencies = dependencies
  end

  def to_s
    "#{name}-#{version}"
  end

  def ==(other)
    other.is_a?(Package) && name == other.name && version == other.version
  end

  def hash
    [name, version].hash
  end
end
