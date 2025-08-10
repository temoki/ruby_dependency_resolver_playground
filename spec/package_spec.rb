require 'spec_helper'

RSpec.describe Package do
  describe '#initialize' do
    context '全パラメータを指定した場合' do
      it 'name, version, dependenciesが正しく設定される' do
        dependencies = [
          Dependency.new('dep1', '>= 1.0.0'),
          Dependency.new('dep2', '~> 2.0')
        ]
        package = Package.new('test-package', '1.0.0', dependencies)
        
        expect(package.name).to eq('test-package')
        expect(package.version).to eq('1.0.0')
        expect(package.dependencies).to eq(dependencies)
      end
    end

    context 'dependenciesを省略した場合' do
      it 'dependenciesが空配列になる' do
        package = Package.new('test-package', '1.0.0')
        
        expect(package.name).to eq('test-package')
        expect(package.version).to eq('1.0.0')
        expect(package.dependencies).to eq([])
      end
    end

    context 'dependenciesにハッシュが含まれる場合' do
      it 'ArgumentErrorを発生させる' do
        dependencies = [
          { name: 'dep1', version: '>= 1.0.0' }
        ]
        
        expect {
          Package.new('test-package', '1.0.0', dependencies)
        }.to raise_error(ArgumentError, /Only Dependency objects are allowed/)
      end
    end

    context 'dependenciesに文字列が含まれる場合' do
      it 'ArgumentErrorを発生させる' do
        dependencies = ['dep1']
        
        expect {
          Package.new('test-package', '1.0.0', dependencies)
        }.to raise_error(ArgumentError, /Only Dependency objects are allowed/)
      end
    end

    context '混在したdependenciesの場合' do
      it 'Dependencyオブジェクト以外でArgumentErrorを発生させる' do
        dependencies = [
          Dependency.new('dep1', '>= 1.0.0'),
          { name: 'dep2', version: '~> 2.0' }  # これがエラーになる
        ]
        
        expect {
          Package.new('test-package', '1.0.0', dependencies)
        }.to raise_error(ArgumentError, /Only Dependency objects are allowed/)
      end
    end

    context 'パラメータにnilが含まれる場合' do
      it 'nilも正常に処理される' do
        package = Package.new(nil, nil, nil)
        
        expect(package.name).to be_nil
        expect(package.version).to be_nil
        expect(package.dependencies).to eq([])
      end
    end

    context '不正なdependencies形式の場合' do
      it 'Dependency以外の型に対してArgumentErrorを発生させる' do
        expect {
          Package.new('test-package', '1.0.0', [123])
        }.to raise_error(ArgumentError, /Only Dependency objects are allowed/)
      end

      it 'Hash形式に対してArgumentErrorを発生させる' do
        expect {
          Package.new('test-package', '1.0.0', [{ name: 'dep1', version: '1.0.0' }])
        }.to raise_error(ArgumentError, /Only Dependency objects are allowed/)
      end

      it 'String形式に対してArgumentErrorを発生させる' do
        expect {
          Package.new('test-package', '1.0.0', ['dep1'])
        }.to raise_error(ArgumentError, /Only Dependency objects are allowed/)
      end
    end

    context '特殊文字を含む場合' do
      it '特殊文字も正常に処理される' do
        dependencies = [
          Dependency.new('dep-1', '>= 1.0.0-beta')
        ]
        package = Package.new('test-package!@#', '1.0.0-beta+123', dependencies)
        
        expect(package.name).to eq('test-package!@#')
        expect(package.version).to eq('1.0.0-beta+123')
        expect(package.dependencies[0].name).to eq('dep-1')
        expect(package.dependencies[0].version_constraint).to be_a(VersionConstraint)
        expect(package.dependencies[0].version_constraint.to_s).to eq('>= 1.0.0.pre.beta')
      end
    end
  end

  describe '#name, #version, #dependencies' do
    let(:dependencies) { [Dependency.new('dep1', '>= 1.0.0'), Dependency.new('dep2', '~> 2.0')] }
    let(:package) { Package.new('test-package', '1.0.0', dependencies) }

    it 'nameを読み取れる' do
      expect(package.name).to eq('test-package')
    end

    it 'versionを読み取れる' do
      expect(package.version).to eq('1.0.0')
    end

    it 'dependenciesを読み取れる' do
      expect(package.dependencies).to eq(dependencies)
    end

    it '属性は読み取り専用である' do
      expect(package).not_to respond_to(:name=)
      expect(package).not_to respond_to(:version=)
      expect(package).not_to respond_to(:dependencies=)
    end
  end

  describe '#to_s' do
    it '正常なフォーマットで文字列を返す' do
      package = Package.new('test-package', '1.0.0')
      expect(package.to_s).to eq('test-package-1.0.0')
    end

    context 'nilが含まれる場合' do
      it 'nilも含めて文字列化される' do
        package = Package.new(nil, '1.0.0')
        expect(package.to_s).to eq('-1.0.0')
        
        package2 = Package.new('test-package', nil)
        expect(package2.to_s).to eq('test-package-')
        
        package3 = Package.new(nil, nil)
        expect(package3.to_s).to eq('-')
      end
    end

    context '空文字列が含まれる場合' do
      it '空文字列も含めて文字列化される' do
        package = Package.new('', '1.0.0')
        expect(package.to_s).to eq('-1.0.0')
        
        package2 = Package.new('test-package', '')
        expect(package2.to_s).to eq('test-package-')
      end
    end

    context '特殊文字が含まれる場合' do
      it '特殊文字も含めて文字列化される' do
        package = Package.new('test-package!@#', '1.0.0-beta+123')
        expect(package.to_s).to eq('test-package!@#-1.0.0-beta+123')
      end
    end
  end

  describe '#==' do
    let(:package1) { Package.new('test-package', '1.0.0', [Dependency.new('dep1', '>= 1.0.0')]) }
    let(:package2) { Package.new('test-package', '1.0.0', [Dependency.new('dep2', '~> 2.0')]) }
    let(:package3) { Package.new('other-package', '1.0.0', [Dependency.new('dep1', '>= 1.0.0')]) }
    let(:package4) { Package.new('test-package', '2.0.0', [Dependency.new('dep1', '>= 1.0.0')]) }

    context '同じname, versionを持つ場合' do
      it 'dependenciesが異なっても等価とみなされる' do
        expect(package1).to eq(package2)
      end

      it '同じオブジェクトは等価' do
        expect(package1).to eq(package1)
      end
    end

    context '異なるnameを持つ場合' do
      it '等価でない' do
        expect(package1).not_to eq(package3)
      end
    end

    context '異なるversionを持つ場合' do
      it '等価でない' do
        expect(package1).not_to eq(package4)
      end
    end

    context '異なるクラスのオブジェクトとの比較' do
      it 'String等の他のクラスとは等価でない' do
        expect(package1).not_to eq('test-package-1.0.0')
        expect(package1).not_to eq(123)
        expect(package1).not_to eq(['test-package', '1.0.0'])
      end
    end

    context 'nilとの比較' do
      it 'nilとは等価でない' do
        expect(package1).not_to eq(nil)
      end
    end

    context 'nilを含むパッケージの比較' do
      it 'nilのname/versionでも正しく比較される' do
        package_nil1 = Package.new(nil, '1.0.0')
        package_nil2 = Package.new(nil, '1.0.0')
        package_nil3 = Package.new(nil, '2.0.0')
        
        expect(package_nil1).to eq(package_nil2)
        expect(package_nil1).not_to eq(package_nil3)
      end
    end
  end

  describe '#hash' do
    let(:package1) { Package.new('test-package', '1.0.0', [Dependency.new('dep1', '>= 1.0.0')]) }
    let(:package2) { Package.new('test-package', '1.0.0', [Dependency.new('dep2', '~> 2.0')]) }
    let(:package3) { Package.new('other-package', '1.0.0', [Dependency.new('dep1', '>= 1.0.0')]) }

    context '同じname, versionを持つ場合' do
      it '同じハッシュ値を返す' do
        expect(package1.hash).to eq(package2.hash)
      end
    end

    context '異なるname, versionを持つ場合' do
      it '異なるハッシュ値を返す' do
        expect(package1.hash).not_to eq(package3.hash)
      end
    end

    it 'ハッシュのキーとして使用できる' do
      hash = {}
      hash[package1] = 'value1'
      hash[package2] = 'value2'  # package1と同じキーとして扱われる
      hash[package3] = 'value3'
      
      expect(hash[package1]).to eq('value2')  # package2で上書きされる
      expect(hash[package2]).to eq('value2')
      expect(hash[package3]).to eq('value3')
      expect(hash.size).to eq(2)
    end

    context 'nilを含むパッケージ' do
      it 'nilでもハッシュ値を生成できる' do
        package_nil = Package.new(nil, nil)
        expect { package_nil.hash }.not_to raise_error
        expect(package_nil.hash).to be_a(Integer)
      end
    end
  end

  describe '#eql?' do
    let(:package1) { Package.new('test-package', '1.0.0', [Dependency.new('dep1', '>= 1.0.0')]) }
    let(:package2) { Package.new('test-package', '1.0.0', [Dependency.new('dep2', '~> 2.0')]) }
    let(:package3) { Package.new('other-package', '1.0.0', [Dependency.new('dep1', '>= 1.0.0')]) }

    it '==と同じ動作をする' do
      expect(package1.eql?(package2)).to eq(package1 == package2)
      expect(package1.eql?(package3)).to eq(package1 == package3)
    end

    it 'ハッシュキーとして正しく動作する' do
      expect(package1.eql?(package2)).to be true
      expect(package1.eql?(package3)).to be false
    end
  end

  describe '不変性' do
    let(:dependencies) { [Dependency.new('dep1', '>= 1.0.0'), Dependency.new('dep2', '~> 2.0')] }
    let(:package) { Package.new('test-package', '1.0.0', dependencies) }

    it 'dependenciesは凍結されており変更できない' do
      expect(package.dependencies).to be_frozen
      expect { package.dependencies << Dependency.new('new-dep') }.to raise_error(FrozenError)
    end

    it 'dependenciesを直接変更してもパッケージに影響しない' do
      original_package_deps = package.dependencies.dup
      dependencies << Dependency.new('new-dep')
      
      expect(package.dependencies).to eq(original_package_deps)
    end
  end

  describe 'エッジケース' do
    context '空文字列' do
      it '空文字列でもパッケージを作成できる' do
        package = Package.new('', '', [])
        
        expect(package.name).to eq('')
        expect(package.version).to eq('')
        expect(package.dependencies).to eq([])
      end
    end

    context '大きなdependencies配列' do
      it '大量の依存関係でも正常に処理される' do
        large_deps = (1..1000).map { |i| Dependency.new("dep#{i}", ">= #{i}.0.0") }
        package = Package.new('test-package', '1.0.0', large_deps)
        
        expect(package.dependencies.size).to eq(1000)
        expect(package.dependencies.first.name).to eq('dep1')
        expect(package.dependencies.last.name).to eq('dep1000')
        expect(package.dependencies).to all(be_a(Dependency))
      end
    end

    context 'Unicode文字' do
      it 'Unicode文字を含むname（バージョンは通常の形式）でも正常に処理される' do
        dependencies = [Dependency.new('依存1', '>= 1.0.0')]
        package = Package.new('テスト-パッケージ', '1.0.0', dependencies)
        
        expect(package.name).to eq('テスト-パッケージ')
        expect(package.version).to eq('1.0.0')
        expect(package.to_s).to eq('テスト-パッケージ-1.0.0')
        expect(package.dependencies[0].name).to eq('依存1')
      end
    end
  end
end
