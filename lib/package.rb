require_relative 'dependency'

# パッケージを表現するクラス
class Package
  attr_reader :name, :version, :dependencies

  def initialize(name, version, dependencies = [])
    @name = name
    @version = version
    @dependencies = normalize_dependencies(dependencies).dup.freeze
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

  private

  def normalize_dependencies(deps)
    return [] if deps.nil?
    
    deps.map do |dep|
      case dep
      when Dependency
        dep
      when Hash
        validate_dependency_hash(dep)
        Dependency.new(dep[:name], dep[:version])
      when String
        Dependency.new(dep)
      else
        raise ArgumentError, "Invalid dependency type: #{dep.class}. Expected Dependency, Hash, or String."
      end
    end
  end

  def validate_dependency_hash(hash)
    unless hash.key?(:name)
      raise ArgumentError, "Dependency hash must contain :name key"
    end
    
    unless hash[:name].is_a?(String)
      raise ArgumentError, "Dependency name must be a String"
    end
  end
end
