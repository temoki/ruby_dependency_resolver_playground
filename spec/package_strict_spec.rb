require 'spec_helper'

RSpec.describe Package do
  describe '厳密な型制限を持つPackage' do
    let(:valid_version) { Gem::Version.new('1.0.0') }
    let(:valid_dependency) { Gem::Dependency.new('rack', '>= 2.0.0') }

    it '正しい型でPackageを作成できる' do
      package = Package.new('test', valid_version, [valid_dependency])
      
      expect(package.name).to eq('test')
      expect(package.version).to eq(valid_version)
      expect(package.dependencies).to eq([valid_dependency])
      expect(package.dependencies).to be_frozen
    end

    it '依存関係なしでPackageを作成できる' do
      package = Package.new('test', valid_version)
      
      expect(package.dependencies).to eq([])
      expect(package.dependencies).to be_frozen
    end

    it 'nilの依存関係も空配列として扱う' do
      package = Package.new('test', valid_version, nil)
      
      expect(package.dependencies).to eq([])
      expect(package.dependencies).to be_frozen
    end

    describe 'バージョンの型チェック' do
      it 'Gem::Version以外を拒否する' do
        expect {
          Package.new('test', '1.0.0')  # 文字列
        }.to raise_error(ArgumentError, /Version must be a Gem::Version, got String/)

        expect {
          Package.new('test', 123)  # 数値
        }.to raise_error(ArgumentError, /Version must be a Gem::Version, got Integer/)

        expect {
          Package.new('test', nil)  # nil
        }.to raise_error(ArgumentError, /Version must be a Gem::Version, got NilClass/)

        expect {
          Package.new('test', [])  # 配列
        }.to raise_error(ArgumentError, /Version must be a Gem::Version, got Array/)
      end
    end

    describe '依存関係の型チェック' do
      it 'Array以外を拒否する' do
        expect {
          Package.new('test', valid_version, 'not_array')
        }.to raise_error(ArgumentError, /Dependencies must be an Array, got String/)

        expect {
          Package.new('test', valid_version, valid_dependency)  # 単体のDependency
        }.to raise_error(ArgumentError, /Dependencies must be an Array, got Gem::Dependency/)
      end

      it '配列内のGem::Dependency以外を拒否する' do
        expect {
          Package.new('test', valid_version, ['string_dep'])
        }.to raise_error(ArgumentError, /Dependencies\[0\] must be a Gem::Dependency, got String/)

        expect {
          Package.new('test', valid_version, [valid_dependency, 123])
        }.to raise_error(ArgumentError, /Dependencies\[1\] must be a Gem::Dependency, got Integer/)

        expect {
          Package.new('test', valid_version, [valid_dependency, nil])
        }.to raise_error(ArgumentError, /Dependencies\[1\] must be a Gem::Dependency, got NilClass/)
      end
    end

    describe '不変性' do
      it '依存関係配列は不変である' do
        deps = [valid_dependency]
        package = Package.new('test', valid_version, deps)
        
        expect(package.dependencies).to be_frozen
        expect {
          package.dependencies << Gem::Dependency.new('new', '1.0.0')
        }.to raise_error(FrozenError)
      end

      it '元の配列を変更してもパッケージの依存関係は影響を受けない' do
        deps = [valid_dependency]
        package = Package.new('test', valid_version, deps)
        
        original_deps = package.dependencies.dup
        deps << Gem::Dependency.new('new', '1.0.0')
        
        expect(package.dependencies).to eq(original_deps)
      end
    end

    describe '基本機能' do
      let(:package1) { Package.new('test', Gem::Version.new('1.0.0'), [valid_dependency]) }
      let(:package2) { Package.new('test', Gem::Version.new('1.0.0'), []) }
      let(:package3) { Package.new('other', Gem::Version.new('1.0.0'), [valid_dependency]) }

      it 'to_sメソッドが正しく動作する' do
        expect(package1.to_s).to eq('test-1.0.0')
      end

      it '等価性比較が正しく動作する' do
        package1_dup = Package.new('test', Gem::Version.new('1.0.0'), [valid_dependency])
        
        expect(package1).to eq(package1_dup)
        expect(package1).to eq(package2)  # 依存関係は等価性比較に影響しない
        expect(package1).not_to eq(package3)  # 異なる名前
      end

      it 'ハッシュキーとして使用できる' do
        hash = {}
        hash[package1] = 'value1'
        hash[package2] = 'value2'
        
        expect(hash[package1]).to eq('value2')  # 同じキー（name + version）
        expect(hash.size).to eq(1)
      end
    end
  end
end
