require 'rubygems'

# バージョン制約を表現するクラス
class VersionConstraint
  # 演算子の列挙型
  module Operator
    EQUAL = :equal                    # =
    GREATER_THAN = :greater_than      # >
    GREATER_THAN_OR_EQUAL = :greater_than_or_equal      # >=
    LESS_THAN = :less_than           # <
    LESS_THAN_OR_EQUAL = :less_than_or_equal        # <=
    PESSIMISTIC = :pessimistic       # ~>
    
    # エイリアス
    GTE = GREATER_THAN_OR_EQUAL
    LTE = LESS_THAN_OR_EQUAL
    
    ALL = [EQUAL, GREATER_THAN, GREATER_THAN_OR_EQUAL, 
           LESS_THAN, LESS_THAN_OR_EQUAL, PESSIMISTIC].freeze
    
    def self.to_string(operator)
      case operator
      when EQUAL then '='
      when GREATER_THAN then '>'
      when GREATER_THAN_OR_EQUAL then '>='
      when LESS_THAN then '<'
      when LESS_THAN_OR_EQUAL then '<='
      when PESSIMISTIC then '~>'
      else
        raise ArgumentError, "Unknown operator: #{operator}"
      end
    end
  end

  attr_reader :operator, :version

  def initialize(operator:, version:)
    unless Operator::ALL.include?(operator)
      raise ArgumentError, "Invalid operator: #{operator}. Must be one of #{Operator::ALL}"
    end
    
    @operator = operator
    @version = case version
               when Gem::Version
                 version
               when String
                 Gem::Version.new(version)
               else
                 raise ArgumentError, "Version must be a String or Gem::Version, got #{version.class}"
               end
  end

  def to_s
    "#{Operator.to_string(operator)} #{version}"
  end

  def ==(other)
    other.is_a?(VersionConstraint) && 
      operator == other.operator && 
      version == other.version
  end

  def hash
    [operator, version].hash
  end

  def eql?(other)
    self == other
  end

  # ファクトリーメソッド群
  def self.equal(version)
    new(operator: Operator::EQUAL, version: version)
  end

  def self.gt(version)
    new(operator: Operator::GREATER_THAN, version: version)
  end

  def self.gte(version)
    new(operator: Operator::GREATER_THAN_OR_EQUAL, version: version)
  end

  def self.lt(version)
    new(operator: Operator::LESS_THAN, version: version)
  end

  def self.lte(version)
    new(operator: Operator::LESS_THAN_OR_EQUAL, version: version)
  end

  def self.pessimistic(version)
    new(operator: Operator::PESSIMISTIC, version: version)
  end

  # エイリアス
  class << self
    alias_method :eq, :equal
    alias_method :greater_than, :gt
    alias_method :greater_than_or_equal, :gte
    alias_method :less_than, :lt
    alias_method :less_than_or_equal, :lte
    alias_method :compatible, :pessimistic
    alias_method :twiddle_wakka, :pessimistic
  end

  # 指定されたバージョンが制約を満たすかチェック
  def satisfied_by?(version)
    target_version = case version
                     when Gem::Version
                       version
                     when String
                       Gem::Version.new(version)
                     else
                       raise ArgumentError, "Target version must be a String or Gem::Version, got #{version.class}"
                     end
    
    case @operator
    when Operator::EQUAL
      target_version == @version
    when Operator::GREATER_THAN
      target_version > @version
    when Operator::GREATER_THAN_OR_EQUAL
      target_version >= @version
    when Operator::LESS_THAN
      target_version < @version
    when Operator::LESS_THAN_OR_EQUAL
      target_version <= @version
    when Operator::PESSIMISTIC
      # ~> 1.2.3 は >= 1.2.3 && < 1.3.0 の意味
      # ~> 2.1 は >= 2.1.0 && < 2.2 の意味
      return false if target_version < @version
      
      # バージョンの最後の部分を除いて比較
      version_parts = @version.version.split('.')
      target_parts = target_version.version.split('.')
      
      # 最後の部分以外は同じでなければならない
      (0...(version_parts.length - 1)).each do |i|
        return false unless target_parts[i] == version_parts[i]
      end
      
      true
    else
      raise ArgumentError, "Unknown operator: #{@operator}"
    end
  end
end
