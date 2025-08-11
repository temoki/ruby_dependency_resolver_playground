class Dependency
  attr_reader :name, :requirement

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
end
