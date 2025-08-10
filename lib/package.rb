require 'rubygems'

# パッケージを表現するクラス
class Package
  attr_reader :name, :version, :dependencies

  def initialize(name, version, dependencies)
    unless name.is_a?(String)
      raise TypeError, "`name` must be a String"
    end
    @name = name

    unless version.is_a?(Gem::Version)
      raise TypeError, "`version` must be a Gem::Version"
    end
    @version = version

    unless dependencies.is_a?(Array)
      raise TypeError, "`dependencies` must be an Array"
    end
    unless dependencies.all? { |dep| dep.is_a?(Gem::Dependency) }
      raise TypeError, "All elements in `dependencies` must be Gem::Dependency"
    end
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

  def eql?(other)
    self == other
  end
end
