require 'spec_helper'

RSpec.describe Dependency do
  describe '#initialize' do
    context '名前のみ指定した場合' do
      it 'nameが設定され、version_constraintはnil' do
        dependency = Dependency.new('rack')
        
        expect(dependency.name).to eq('rack')
        expect(dependency.version_constraint).to be_nil
      end
    end

    context 'VersionConstraintオブジェクトを指定した場合' do
      it 'VersionConstraintが正しく設定される' do
        constraint = VersionConstraint.gte('2.0.0')
        dependency = Dependency.new('rack', constraint)
        
        expect(dependency.name).to eq('rack')
        expect(dependency.version_constraint).to eq(constraint)
      end
    end

    context '文字列のバージョン制約を指定した場合（後方互換性）' do
      it '文字列からVersionConstraintに変換される' do
        dependency = Dependency.new('rack', '>= 2.0.0')
        
        expect(dependency.name).to eq('rack')
        expect(dependency.version_constraint).to be_a(VersionConstraint)
        expect(dependency.version_constraint.to_s).to eq('>= 2.0.0')
      end

      it '様々な演算子をサポートする' do
        test_cases = [
          ['>= 2.0.0', VersionConstraint::Operator::GREATER_THAN_OR_EQUAL],
          ['> 2.0.0', VersionConstraint::Operator::GREATER_THAN],
          ['<= 2.0.0', VersionConstraint::Operator::LESS_THAN_OR_EQUAL],
          ['< 2.0.0', VersionConstraint::Operator::LESS_THAN],
          ['~> 2.0', VersionConstraint::Operator::PESSIMISTIC],
          ['= 2.0.0', VersionConstraint::Operator::EQUAL],
          ['2.0.0', VersionConstraint::Operator::EQUAL]  # 演算子なし
        ]

        test_cases.each do |constraint_str, expected_operator|
          dependency = Dependency.new('test', constraint_str)
          expect(dependency.version_constraint.operator).to eq(expected_operator)
        end
      end
    end

    context 'nilが含まれる場合' do
      it 'nilも正常に処理される' do
        dependency = Dependency.new(nil, nil)
        
        expect(dependency.name).to be_nil
        expect(dependency.version_constraint).to be_nil
      end
    end

    context '不正なバージョン制約の場合' do
      it 'ArgumentErrorを発生させる' do
        expect {
          Dependency.new('rack', 123)
        }.to raise_error(ArgumentError, /Version constraint must be nil, VersionConstraint, or String/)
      end
    end
  end

  describe '#name, #version_constraint' do
    let(:dependency) { Dependency.new('rack', '>= 2.0.0') }

    it 'nameを読み取れる' do
      expect(dependency.name).to eq('rack')
    end

    it 'version_constraintを読み取れる' do
      expect(dependency.version_constraint).to be_a(VersionConstraint)
      expect(dependency.version_constraint.to_s).to eq('>= 2.0.0')
    end

    it '属性は読み取り専用である' do
      expect(dependency).not_to respond_to(:name=)
      expect(dependency).not_to respond_to(:version_constraint=)
    end
  end

  describe '#to_s' do
    context 'バージョン制約がある場合' do
      it '名前とバージョン制約を含む文字列を返す' do
        dependency = Dependency.new('rack', '>= 2.0.0')
        expect(dependency.to_s).to eq('rack (>= 2.0.0)')
      end
    end

    context 'バージョン制約がない場合' do
      it '名前のみを返す' do
        dependency = Dependency.new('rack')
        expect(dependency.to_s).to eq('rack')
      end
    end

    context 'nilが含まれる場合' do
      it 'nilも含めて文字列化される' do
        dependency = Dependency.new(nil, '>= 2.0.0')
        expect(dependency.to_s).to eq(' (>= 2.0.0)')
        
        dependency2 = Dependency.new('rack', nil)
        expect(dependency2.to_s).to eq('rack')
        
        dependency3 = Dependency.new(nil, nil)
        expect(dependency3.to_s).to eq('')
      end
    end
  end

  describe '#==' do
    let(:dependency1) { Dependency.new('rack', '>= 2.0.0') }
    let(:dependency2) { Dependency.new('rack', '>= 2.0.0') }
    let(:dependency3) { Dependency.new('sinatra', '>= 2.0.0') }
    let(:dependency4) { Dependency.new('rack', '~> 2.0') }

    context '同じname, version_constraintを持つ場合' do
      it '等価とみなされる' do
        expect(dependency1).to eq(dependency2)
      end

      it '同じオブジェクトは等価' do
        expect(dependency1).to eq(dependency1)
      end
    end

    context '異なるnameを持つ場合' do
      it '等価でない' do
        expect(dependency1).not_to eq(dependency3)
      end
    end

    context '異なるversion_constraintを持つ場合' do
      it '等価でない' do
        expect(dependency1).not_to eq(dependency4)
      end
    end

    context '異なるクラスのオブジェクトとの比較' do
      it 'String等の他のクラスとは等価でない' do
        expect(dependency1).not_to eq('rack (>= 2.0.0)')
        expect(dependency1).not_to eq(['rack', '>= 2.0.0'])
      end
    end

    context 'nilとの比較' do
      it 'nilとは等価でない' do
        expect(dependency1).not_to eq(nil)
      end
    end
  end

  describe '#hash' do
    let(:dependency1) { Dependency.new('rack', '>= 2.0.0') }
    let(:dependency2) { Dependency.new('rack', '>= 2.0.0') }
    let(:dependency3) { Dependency.new('sinatra', '>= 2.0.0') }

    context '同じname, version_constraintを持つ場合' do
      it '同じハッシュ値を返す' do
        expect(dependency1.hash).to eq(dependency2.hash)
      end
    end

    context '異なるname, version_constraintを持つ場合' do
      it '異なるハッシュ値を返す' do
        expect(dependency1.hash).not_to eq(dependency3.hash)
      end
    end

    it 'ハッシュのキーとして使用できる' do
      hash = {}
      hash[dependency1] = 'value1'
      hash[dependency2] = 'value2'  # dependency1と同じキーとして扱われる
      hash[dependency3] = 'value3'
      
      expect(hash[dependency1]).to eq('value2')
      expect(hash[dependency2]).to eq('value2')
      expect(hash[dependency3]).to eq('value3')
      expect(hash.size).to eq(2)
    end
  end

  describe '#eql?' do
    let(:dependency1) { Dependency.new('rack', '>= 2.0.0') }
    let(:dependency2) { Dependency.new('rack', '>= 2.0.0') }
    let(:dependency3) { Dependency.new('sinatra', '>= 2.0.0') }

    it '==と同じ動作をする' do
      expect(dependency1.eql?(dependency2)).to eq(dependency1 == dependency2)
      expect(dependency1.eql?(dependency3)).to eq(dependency1 == dependency3)
    end

    it 'ハッシュキーとして正しく動作する' do
      expect(dependency1.eql?(dependency2)).to be true
      expect(dependency1.eql?(dependency3)).to be false
    end
  end

  describe 'エッジケース' do
    context '空文字列' do
      it '空文字列でも依存関係を作成できる' do
        dependency = Dependency.new('', '')
        
        expect(dependency.name).to eq('')
        expect(dependency.version_constraint).to be_nil
      end
    end

    context 'Unicode文字' do
      it 'Unicode文字を含むname（バージョンは通常の形式）でも正常に処理される' do
        dependency = Dependency.new('パッケージ名', '>= 1.0.0')
        
        expect(dependency.name).to eq('パッケージ名')
        expect(dependency.version_constraint).to be_a(VersionConstraint)
        expect(dependency.version_constraint.to_s).to eq('>= 1.0.0')
      end
    end
  end
end
