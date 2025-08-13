# パッケージのバージョンを表すクラス
class Version
  attr_reader :major, :minor, :patch

  # 初期化
  # @param major [Integer] メジャーバージョン
  # @param minor [Integer] マイナーバージョン（省略時は0）
  # @param patch [Integer] パッチバージョン（省略時は0）
  def initialize(major, minor = 0, patch = 0)
    @major = major
    @minor = minor
    @patch = patch
  end

  def to_s
    "#{major}.#{minor}.#{patch}"
  end

  def ==(other)
    other.is_a?(Version) && major == other.major && minor == other.minor && patch == other.patch
  end

  def hash
    [major, minor, patch].hash
  end

  def eql?(other)
    self == other
  end

  include Comparable

  def <=>(other)
    return nil unless other.is_a?(Version)
    
    # メジャーバージョンを最初に比較
    major_comparison = major <=> other.major
    return major_comparison unless major_comparison.zero?
    
    # メジャーが同じ場合、マイナーバージョンを比較
    minor_comparison = minor <=> other.minor
    return minor_comparison unless minor_comparison.zero?
    
    # メジャーとマイナーが同じ場合、パッチバージョンを比較
    patch <=> other.patch
  end
end
