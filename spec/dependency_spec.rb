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

    context '名前とバージョン制約を指定した場合' do
      it 'name, version_constraintが正しく設定される' do
        dependency = Dependency.new('rack', '>= 2.0.0')
        
        expect(dependency.name).to eq('rack')
        expect(dependency.version_constraint).to eq('>= 2.0.0')
      end
    end

    context 'nilが含まれる場合' do
      it 'nilも正常に処理される' do
        dependency = Dependency.new(nil, nil)
        
        expect(dependency.name).to be_nil
        expect(dependency.version_constraint).to be_nil
      end
    end
  end

  describe '#name, #version_constraint' do
    let(:dependency) { Dependency.new('rack', '>= 2.0.0') }

    it 'nameを読み取れる' do
      expect(dependency.name).to eq('rack')
    end

    it 'version_constraintを読み取れる' do
      expect(dependency.version_constraint).to eq('>= 2.0.0')
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

  describe '.from_hash' do
    context '有効なハッシュの場合' do
      it 'Dependencyオブジェクトを作成する' do
        hash = { name: 'rack', version: '>= 2.0.0' }
        dependency = Dependency.from_hash(hash)
        
        expect(dependency.name).to eq('rack')
        expect(dependency.version_constraint).to eq('>= 2.0.0')
      end

      it 'versionがnilでも作成できる' do
        hash = { name: 'rack', version: nil }
        dependency = Dependency.from_hash(hash)
        
        expect(dependency.name).to eq('rack')
        expect(dependency.version_constraint).to be_nil
      end

      it 'versionキーがなくても作成できる' do
        hash = { name: 'rack' }
        dependency = Dependency.from_hash(hash)
        
        expect(dependency.name).to eq('rack')
        expect(dependency.version_constraint).to be_nil
      end
    end
  end

  describe '#to_hash' do
    it 'ハッシュ形式に変換できる' do
      dependency = Dependency.new('rack', '>= 2.0.0')
      hash = dependency.to_hash
      
      expect(hash).to eq({ name: 'rack', version: '>= 2.0.0' })
    end

    it 'version_constraintがnilでもハッシュ化できる' do
      dependency = Dependency.new('rack')
      hash = dependency.to_hash
      
      expect(hash).to eq({ name: 'rack', version: nil })
    end
  end

  describe 'エッジケース' do
    context '空文字列' do
      it '空文字列でも依存関係を作成できる' do
        dependency = Dependency.new('', '')
        
        expect(dependency.name).to eq('')
        expect(dependency.version_constraint).to eq('')
        expect(dependency.to_s).to eq('')  # 空文字列の場合はnameのみ表示
      end
    end

    context 'Unicode文字' do
      it 'Unicode文字を含むname/version_constraintでも正常に処理される' do
        dependency = Dependency.new('テスト-パッケージ', '>= １.０.０')
        
        expect(dependency.name).to eq('テスト-パッケージ')
        expect(dependency.version_constraint).to eq('>= １.０.０')
        expect(dependency.to_s).to eq('テスト-パッケージ (>= １.０.０)')
      end
    end
  end
end
