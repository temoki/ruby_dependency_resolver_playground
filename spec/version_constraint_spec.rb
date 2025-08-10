require 'spec_helper'

RSpec.describe VersionConstraint do
  describe 'Operator' do
    it '全ての演算子が定義されている' do
      expect(VersionConstraint::Operator::ALL).to include(
        :equal, :greater_than, :greater_than_or_equal, :less_than, :less_than_or_equal, :pessimistic
      )
    end

    describe '.to_string' do
      it '演算子を文字列に変換する' do
        expect(VersionConstraint::Operator.to_string(:equal)).to eq('=')
        expect(VersionConstraint::Operator.to_string(:greater_than)).to eq('>')
        expect(VersionConstraint::Operator.to_string(:greater_than_or_equal)).to eq('>=')
        expect(VersionConstraint::Operator.to_string(:less_than)).to eq('<')
        expect(VersionConstraint::Operator.to_string(:less_than_or_equal)).to eq('<=')
        expect(VersionConstraint::Operator.to_string(:pessimistic)).to eq('~>')
      end

      it '不正な演算子でArgumentErrorを発生させる' do
        expect {
          VersionConstraint::Operator.to_string(:invalid)
        }.to raise_error(ArgumentError, /Unknown operator/)
      end
    end
  end

  describe '#initialize' do
    it '正しい演算子とバージョンで作成される' do
      constraint = VersionConstraint.new(
        operator: VersionConstraint::Operator::GTE, 
        version: '2.0.0'
      )
      
      expect(constraint.operator).to eq(VersionConstraint::Operator::GTE)
      expect(constraint.version).to eq(Gem::Version.new('2.0.0'))
    end

    it 'Gem::Versionを受け入れる' do
      gem_version = Gem::Version.new('1.5.0')
      constraint = VersionConstraint.new(
        operator: VersionConstraint::Operator::EQUAL, 
        version: gem_version
      )
      
      expect(constraint.version).to eq(gem_version)
    end

    it '不正な演算子でArgumentErrorを発生させる' do
      expect {
        VersionConstraint.new(operator: :invalid, version: '1.0.0')
      }.to raise_error(ArgumentError, /Invalid operator/)
    end

    it '不正なバージョン型でArgumentErrorを発生させる' do
      expect {
        VersionConstraint.new(operator: VersionConstraint::Operator::EQUAL, version: 123)
      }.to raise_error(ArgumentError, /Version must be a String or Gem::Version/)
    end
  end

  describe 'ファクトリーメソッド' do
    it '.equal' do
      constraint = VersionConstraint.equal('2.0.0')
      expect(constraint.operator).to eq(VersionConstraint::Operator::EQUAL)
      expect(constraint.version).to eq(Gem::Version.new('2.0.0'))
    end

    it '.gte' do
      constraint = VersionConstraint.gte('2.0.0')
      expect(constraint.operator).to eq(VersionConstraint::Operator::GTE)
      expect(constraint.version).to eq(Gem::Version.new('2.0.0'))
    end

    it '.gt' do
      constraint = VersionConstraint.gt('2.0.0')
      expect(constraint.operator).to eq(VersionConstraint::Operator::GREATER_THAN)
    end

    it '.lte' do
      constraint = VersionConstraint.lte('2.0.0')
      expect(constraint.operator).to eq(VersionConstraint::Operator::LTE)
    end

    it '.lt' do
      constraint = VersionConstraint.lt('2.0.0')
      expect(constraint.operator).to eq(VersionConstraint::Operator::LESS_THAN)
    end

    it '.pessimistic' do
      constraint = VersionConstraint.pessimistic('2.0')
      expect(constraint.operator).to eq(VersionConstraint::Operator::PESSIMISTIC)
    end

    describe 'エイリアス' do
      it '.eq は .equal のエイリアス' do
        expect(VersionConstraint.eq('1.0.0')).to eq(VersionConstraint.equal('1.0.0'))
      end

      it '.compatible は .pessimistic のエイリアス' do
        expect(VersionConstraint.compatible('2.0')).to eq(VersionConstraint.pessimistic('2.0'))
      end
    end
  end

  describe '#to_s' do
    it '演算子とバージョンを文字列として返す' do
      constraint = VersionConstraint.gte('2.0.0')
      expect(constraint.to_s).to eq('>= 2.0.0')
    end

    it 'pessimistic制約の場合' do
      constraint = VersionConstraint.pessimistic('2.1')
      expect(constraint.to_s).to eq('~> 2.1')
    end
  end

  describe '#==' do
    it '同じ演算子とバージョンの場合は等価' do
      constraint1 = VersionConstraint.gte('2.0.0')
      constraint2 = VersionConstraint.gte('2.0.0')
      expect(constraint1).to eq(constraint2)
    end

    it '異なる演算子の場合は非等価' do
      constraint1 = VersionConstraint.gte('2.0.0')
      constraint2 = VersionConstraint.gt('2.0.0')
      expect(constraint1).not_to eq(constraint2)
    end

    it '異なるバージョンの場合は非等価' do
      constraint1 = VersionConstraint.gte('2.0.0')
      constraint2 = VersionConstraint.gte('2.1.0')
      expect(constraint1).not_to eq(constraint2)
    end
  end

  describe '#satisfied_by?' do
    describe '等価制約' do
      let(:constraint) { VersionConstraint.equal('2.0.0') }

      it '同じバージョンで満たされる' do
        expect(constraint.satisfied_by?('2.0.0')).to be true
      end

      it '異なるバージョンで満たされない' do
        expect(constraint.satisfied_by?('2.0.1')).to be false
        expect(constraint.satisfied_by?('1.9.9')).to be false
      end
    end

    describe '>= 制約' do
      let(:constraint) { VersionConstraint.gte('2.0.0') }

      it '同じまたはより新しいバージョンで満たされる' do
        expect(constraint.satisfied_by?('2.0.0')).to be true
        expect(constraint.satisfied_by?('2.0.1')).to be true
        expect(constraint.satisfied_by?('3.0.0')).to be true
      end

      it 'より古いバージョンで満たされない' do
        expect(constraint.satisfied_by?('1.9.9')).to be false
      end
    end

    describe '> 制約' do
      let(:constraint) { VersionConstraint.gt('2.0.0') }

      it 'より新しいバージョンで満たされる' do
        expect(constraint.satisfied_by?('2.0.1')).to be true
        expect(constraint.satisfied_by?('3.0.0')).to be true
      end

      it '同じまたはより古いバージョンで満たされない' do
        expect(constraint.satisfied_by?('2.0.0')).to be false
        expect(constraint.satisfied_by?('1.9.9')).to be false
      end
    end

    describe '<= 制約' do
      let(:constraint) { VersionConstraint.lte('2.0.0') }

      it '同じまたはより古いバージョンで満たされる' do
        expect(constraint.satisfied_by?('2.0.0')).to be true
        expect(constraint.satisfied_by?('1.9.9')).to be true
        expect(constraint.satisfied_by?('1.0.0')).to be true
      end

      it 'より新しいバージョンで満たされない' do
        expect(constraint.satisfied_by?('2.0.1')).to be false
      end
    end

    describe '< 制約' do
      let(:constraint) { VersionConstraint.lt('2.0.0') }

      it 'より古いバージョンで満たされる' do
        expect(constraint.satisfied_by?('1.9.9')).to be true
        expect(constraint.satisfied_by?('1.0.0')).to be true
      end

      it '同じまたはより新しいバージョンで満たされない' do
        expect(constraint.satisfied_by?('2.0.0')).to be false
        expect(constraint.satisfied_by?('2.0.1')).to be false
      end
    end

    describe '~> 制約（pessimistic）' do
      let(:constraint) { VersionConstraint.pessimistic('2.1') }

      it '互換性のあるバージョンで満たされる' do
        expect(constraint.satisfied_by?('2.1.0')).to be true
        expect(constraint.satisfied_by?('2.1.5')).to be true
        expect(constraint.satisfied_by?('2.1.999')).to be true
      end

      it '互換性のないバージョンで満たされない' do
        expect(constraint.satisfied_by?('2.0.0')).to be false
        expect(constraint.satisfied_by?('2.2.0')).to be false
        expect(constraint.satisfied_by?('3.0.0')).to be false
      end
    end

    it 'Gem::Versionも受け入れる' do
      constraint = VersionConstraint.gte('2.0.0')
      gem_version = Gem::Version.new('2.1.0')
      expect(constraint.satisfied_by?(gem_version)).to be true
    end

    it '不正なバージョン型でArgumentErrorを発生させる' do
      constraint = VersionConstraint.gte('2.0.0')
      expect {
        constraint.satisfied_by?(123)
      }.to raise_error(ArgumentError, /Target version must be a String or Gem::Version/)
    end
  end

  describe '#hash と #eql?' do
    it '同じ制約は同じハッシュ値を持つ' do
      constraint1 = VersionConstraint.gte('2.0.0')
      constraint2 = VersionConstraint.gte('2.0.0')
      expect(constraint1.hash).to eq(constraint2.hash)
    end

    it 'ハッシュのキーとして使用できる' do
      hash = {}
      constraint1 = VersionConstraint.gte('2.0.0')
      constraint2 = VersionConstraint.gte('2.0.0')
      
      hash[constraint1] = 'value1'
      hash[constraint2] = 'value2'
      
      expect(hash.size).to eq(1)
      expect(hash[constraint1]).to eq('value2')
    end
  end
end
