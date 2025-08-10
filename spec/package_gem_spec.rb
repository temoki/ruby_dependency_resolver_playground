require 'spec_helper'

RSpec.describe Package do
  describe '標準のGem::Dependencyを使用したPackage' do
    it '標準のGem::Dependencyオブジェクトを受け入れる' do
      dep = Gem::Dependency.new('rack', '>= 2.0.0')
      package = Package.new('sinatra', '2.0.0', [dep])
      
      expect(package.name).to eq('sinatra')
      expect(package.version).to eq(Gem::Version.new('2.0.0'))
      expect(package.dependencies).to eq([dep])
    end

    it '文字列形式の依存関係を自動的にGem::Dependencyに変換する' do
      package = Package.new('sinatra', '2.0.0', ['rack >= 2.0.0'])
      
      expect(package.dependencies.size).to eq(1)
      expect(package.dependencies.first).to be_a(Gem::Dependency)
      expect(package.dependencies.first.name).to eq('rack')
      expect(package.dependencies.first.requirement.to_s).to eq('>= 2.0.0')
    end

    it 'バージョン指定なしの依存関係は">= 0"として扱われる' do
      package = Package.new('app', '1.0.0', ['rake'])
      
      expect(package.dependencies.first.name).to eq('rake')
      expect(package.dependencies.first.requirement.to_s).to eq('>= 0')
    end

    it 'Gem::Versionを使用してバージョン比較ができる' do
      package1 = Package.new('test', '1.0.0')
      package2 = Package.new('test', '2.0.0')
      
      expect(package1.version).to be < package2.version
    end

    it '様々なバージョン制約をサポートする' do
      test_cases = [
        'rack >= 2.0.0',
        'rails ~> 6.0',
        'puma = 5.0.0',
        'nokogiri < 1.12'
      ]
      
      package = Package.new('app', '1.0.0', test_cases)
      
      expect(package.dependencies.size).to eq(4)
      expect(package.dependencies[0].name).to eq('rack')
      expect(package.dependencies[1].name).to eq('rails')
      expect(package.dependencies[2].name).to eq('puma')
      expect(package.dependencies[3].name).to eq('nokogiri')
    end
  end
end
