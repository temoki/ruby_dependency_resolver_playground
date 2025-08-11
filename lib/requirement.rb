class Requirement
  attr_reader :operator, :version

  def initialize(operator, version)
    @operator = operator
    @version = version
  end

  def to_s
    "#{operator} #{version}"
  end

  def ==(other)
    other.is_a?(Requirement) && operator == other.operator && version == other.version
  end

  def hash
    [operator, version].hash
  end

  def eql?(other)
    self == other
  end

  def satisfied_by?(version)
    case operator
    when '='
      version == self.version
    when '>'
      version > self.version
    when '<'
      version < self.version
    when '>='
      version >= self.version
    when '<='
      version <= self.version
    else
      false
    end
  end
end
