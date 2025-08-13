# パッケージの必要条件を表すクラス
class Requirement
  attr_reader :operator, :version

  # 初期化
  # @param operator [String] 演算子（'=', '!=', '>', '<', '>=', '<=', '~>'）
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
    when '!='
      version != self.version
    when '>'
      version > self.version
    when '<'
      version < self.version
    when '>='
      version >= self.version
    when '<='
      version <= self.version
    when '~>'
      pessimistic_satisfied_by?(version)
    else
      false
    end
  end

  private

  # 悲観的バージョンオペレータ（~>）の判定
  # ~> 1.4 は >= 1.4.0 かつ < 2.0.0 を意味する
  # ~> 2.3.1 は >= 2.3.1 かつ < 2.4.0 を意味する
  def pessimistic_satisfied_by?(version)
    # 最低バージョン要件を満たしているかチェック
    return false if version < self.version
    
    # パッチバージョンが指定されている場合（x.y.z で z > 0）
    if self.version.patch > 0
      # メジャーとマイナーが同じで、パッチが上位互換
      version.major == self.version.major && version.minor == self.version.minor
    else
      # パッチが0の場合、メジャーが同じでマイナーが上位互換
      version.major == self.version.major
    end
  end
end
