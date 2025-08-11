class Specification
  attr_reader :name, :version, :dependencies

  def initialize(name, version, dependencies)
    @name = name
    @version = version
    @dependencies = dependencies
  end

  def to_s
    "#{name} #{version}"
  end

  def ==(other)
    other.is_a?(Specification) && name == other.name && version == other.version
  end

  def hash
    [name, version].hash
  end

  def eql?(other)
    self == other
  end
end
