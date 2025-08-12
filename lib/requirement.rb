# パッケージの必要条件を表すクラス
class Requirement
  attr_reader :operator, :version

  # 初期化
  # @param operator [String] 演算子（'=', '>', '<', '>=', '<='）
  # @param version [Version] バージョン
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
