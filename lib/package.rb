require_relative 'dependency'

# パッケージを表現するクラス
class Package
  attr_reader :name, :version, :dependencies

  def initialize(name, version, dependencies = [])
    @name = name
    @version = version
    
    # Dependencies validation
    unless dependencies.nil?
      dependencies.each do |dependency|
        unless dependency.is_a?(Dependency)
          raise ArgumentError, "Invalid dependency type: #{dependency.class}. Only Dependency objects are allowed."
        end
      end
    end
    
    @dependencies = (dependencies || []).dup.freeze
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
