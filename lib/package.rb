require 'rubygems'

# パッケージを表現するクラス
class Package
  attr_reader :name, :version, :dependencies

  def initialize(name, version, dependencies = [])
    @name = name
    @version = version.is_a?(Gem::Version) ? version : Gem::Version.new(version.to_s)
    @dependencies = normalize_dependencies(dependencies)
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
      when Gem::Dependency
        dep
      when String
        # "gem_name >= 1.0.0" 形式の文字列をパース
        parse_dependency_string(dep)
      else
        raise ArgumentError, "Dependencies must be Gem::Dependency objects or strings, got #{dep.class}"
      end
    end
  end

  def parse_dependency_string(dep_string)
    # "gem_name >= 1.0.0" を "gem_name", ">= 1.0.0" に分割
    if dep_string =~ /^(\S+)\s+(.+)$/
      name = $1
      requirement = $2
      Gem::Dependency.new(name, requirement)
    else
      # バージョン指定がない場合
      Gem::Dependency.new(dep_string, '>= 0')
    end
  end
end
