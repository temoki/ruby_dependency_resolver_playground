require 'rubygems'

# パッケージを表現するクラス
class Package
  attr_reader :name, :version, :dependencies

  def initialize(name, version, dependencies = [])
    # バリデーションを先に実行
    validated_version = self.class.validate_version(version)
    validated_dependencies = self.class.validate_dependencies(dependencies)
    
    # 全てのバリデーションが成功した後にインスタンス変数を設定
    @name = name
    @version = validated_version
    @dependencies = validated_dependencies
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

  def self.validate_version(version)
    unless version.is_a?(Gem::Version)
      raise ArgumentError, "Version must be a Gem::Version, got #{version.class}"
    end
    version
  end

  def self.validate_dependencies(deps)
    return [].freeze if deps.nil?
    
    unless deps.is_a?(Array)
      raise ArgumentError, "Dependencies must be an Array, got #{deps.class}"
    end
    
    deps.each_with_index do |dep, index|
      unless dep.is_a?(Gem::Dependency)
        raise ArgumentError, "Dependencies[#{index}] must be a Gem::Dependency, got #{dep.class}"
      end
    end
    
    deps.dup.freeze  # 配列を不変にして型安全性を向上
  end
end
