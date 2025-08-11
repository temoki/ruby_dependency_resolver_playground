class Version
  attr_reader :major

  def initialize(major)
    @major = major
  end

  def to_s
    "#{major}"
  end

  def ==(other)
    other.is_a?(Version) && major == other.major
  end

  def hash
    [major].hash
  end

  def eql?(other)
    self == other
  end

  include Comparable

  def <=>(other)
    return nil unless other.is_a?(Version)
    major <=> other.major
  end
end
