require 'rspec'
require 'spec_helper'
require 'rubygems'

RSpec.describe Package do
  let(:valid_name) { "test_package" }
  let(:valid_version) { Gem::Version.new("1.0.0") }
  let(:valid_dependencies) { [] }
  let(:valid_dependency) { Gem::Dependency.new("dep1", "~> 1.0") }

  describe '#initialize' do
    context 'with valid arguments' do
      it 'creates a package with empty dependencies' do
        package = Package.new(valid_name, valid_version, [])
        expect(package.name).to eq(valid_name)
        expect(package.version).to eq(valid_version)
        expect(package.dependencies).to eq([])
      end

      it 'creates a package with valid dependencies' do
        dependencies = [valid_dependency]
        package = Package.new(valid_name, valid_version, dependencies)
        expect(package.name).to eq(valid_name)
        expect(package.version).to eq(valid_version)
        expect(package.dependencies).to eq(dependencies)
      end

      it 'creates a package with multiple valid dependencies' do
        dep1 = Gem::Dependency.new("dep1", "~> 1.0")
        dep2 = Gem::Dependency.new("dep2", ">= 2.0")
        dependencies = [dep1, dep2]
        package = Package.new(valid_name, valid_version, dependencies)
        expect(package.dependencies).to eq(dependencies)
      end
    end

    context 'with invalid name' do
      it 'raises TypeError when name is not a String' do
        expect { Package.new(123, valid_version, valid_dependencies) }
          .to raise_error(TypeError, "`name` must be a String")
      end

      it 'raises TypeError when name is nil' do
        expect { Package.new(nil, valid_version, valid_dependencies) }
          .to raise_error(TypeError, "`name` must be a String")
      end
    end

    context 'with invalid version' do
      it 'raises TypeError when version is not a Gem::Version' do
        expect { Package.new(valid_name, "1.0.0", valid_dependencies) }
          .to raise_error(TypeError, "`version` must be a Gem::Version")
      end

      it 'raises TypeError when version is nil' do
        expect { Package.new(valid_name, nil, valid_dependencies) }
          .to raise_error(TypeError, "`version` must be a Gem::Version")
      end
    end

    context 'with invalid dependencies' do
      it 'raises TypeError when dependencies is not an Array' do
        expect { Package.new(valid_name, valid_version, "not_array") }
          .to raise_error(TypeError, "`dependencies` must be an Array")
      end

      it 'raises TypeError when dependencies is nil' do
        expect { Package.new(valid_name, valid_version, nil) }
          .to raise_error(TypeError, "`dependencies` must be an Array")
      end

      it 'raises TypeError when dependencies contains non-Gem::Dependency elements' do
        invalid_dependencies = [valid_dependency, "not_a_dependency"]
        expect { Package.new(valid_name, valid_version, invalid_dependencies) }
          .to raise_error(TypeError, "All elements in `dependencies` must be Gem::Dependency")
      end

      it 'raises TypeError when dependencies contains only invalid elements' do
        invalid_dependencies = ["not_a_dependency", 123]
        expect { Package.new(valid_name, valid_version, invalid_dependencies) }
          .to raise_error(TypeError, "All elements in `dependencies` must be Gem::Dependency")
      end
    end
  end

  describe '#to_s' do
    it 'returns name-version format' do
      package = Package.new(valid_name, valid_version, valid_dependencies)
      expect(package.to_s).to eq("test_package-1.0.0")
    end
  end

  describe '#==' do
    let(:package1) { Package.new("pkg", Gem::Version.new("1.0.0"), []) }
    let(:package2) { Package.new("pkg", Gem::Version.new("1.0.0"), []) }
    let(:package3) { Package.new("pkg", Gem::Version.new("2.0.0"), []) }
    let(:package4) { Package.new("other", Gem::Version.new("1.0.0"), []) }

    it 'returns true for packages with same name and version' do
      expect(package1 == package2).to be true
    end

    it 'returns false for packages with different versions' do
      expect(package1 == package3).to be false
    end

    it 'returns false for packages with different names' do
      expect(package1 == package4).to be false
    end

    it 'returns false when comparing with non-Package object' do
      expect(package1 == "not_a_package").to be false
    end

    it 'returns false when comparing with nil' do
      expect(package1 == nil).to be false
    end
  end

  describe '#hash' do
    it 'returns same hash for equal packages' do
      package1 = Package.new("pkg", Gem::Version.new("1.0.0"), [])
      package2 = Package.new("pkg", Gem::Version.new("1.0.0"), [])
      expect(package1.hash).to eq(package2.hash)
    end

    it 'returns different hash for packages with different names' do
      package1 = Package.new("pkg1", Gem::Version.new("1.0.0"), [])
      package2 = Package.new("pkg2", Gem::Version.new("1.0.0"), [])
      expect(package1.hash).not_to eq(package2.hash)
    end

    it 'returns different hash for packages with different versions' do
      package1 = Package.new("pkg", Gem::Version.new("1.0.0"), [])
      package2 = Package.new("pkg", Gem::Version.new("2.0.0"), [])
      expect(package1.hash).not_to eq(package2.hash)
    end
  end

  describe '#eql?' do
    let(:package1) { Package.new("pkg", Gem::Version.new("1.0.0"), []) }
    let(:package2) { Package.new("pkg", Gem::Version.new("1.0.0"), []) }
    let(:package3) { Package.new("pkg", Gem::Version.new("2.0.0"), []) }

    it 'returns true for equal packages' do
      expect(package1.eql?(package2)).to be true
    end

    it 'returns false for different packages' do
      expect(package1.eql?(package3)).to be false
    end

    it 'returns false when comparing with non-Package object' do
      expect(package1.eql?("not_a_package")).to be false
    end
  end

  describe 'hash consistency' do
    it 'allows packages to be used as hash keys' do
      package1 = Package.new("pkg", Gem::Version.new("1.0.0"), [])
      package2 = Package.new("pkg", Gem::Version.new("1.0.0"), [])
      
      hash = {}
      hash[package1] = "value1"
      hash[package2] = "value2"
      
      # Same packages should overwrite the value
      expect(hash.keys.length).to eq(1)
      expect(hash[package1]).to eq("value2")
      expect(hash[package2]).to eq("value2")
    end
  end
end