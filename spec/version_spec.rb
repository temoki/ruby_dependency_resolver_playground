require 'spec_helper'
require_relative '../lib/version'

RSpec.describe Version do
  describe '#initialize' do
    it 'sets the major version' do
      version = Version.new(1)
      expect(version.major).to eq(1)
      expect(version.minor).to eq(0)
      expect(version.patch).to eq(0)
    end

    it 'sets major and minor versions' do
      version = Version.new(1, 2)
      expect(version.major).to eq(1)
      expect(version.minor).to eq(2)
      expect(version.patch).to eq(0)
    end

    it 'sets major, minor, and patch versions' do
      version = Version.new(1, 2, 3)
      expect(version.major).to eq(1)
      expect(version.minor).to eq(2)
      expect(version.patch).to eq(3)
    end

    it 'accepts different major versions with defaults' do
      version = Version.new(5)
      expect(version.major).to eq(5)
      expect(version.minor).to eq(0)
      expect(version.patch).to eq(0)
    end
  end

  describe '#to_s' do
    it 'returns semantic version string for major only' do
      version = Version.new(2)
      expect(version.to_s).to eq('2.0.0')
    end

    it 'returns semantic version string for major and minor' do
      version = Version.new(1, 5)
      expect(version.to_s).to eq('1.5.0')
    end

    it 'returns semantic version string for major, minor, and patch' do
      version = Version.new(1, 2, 3)
      expect(version.to_s).to eq('1.2.3')
    end

    it 'works with different major versions' do
      version = Version.new(10)
      expect(version.to_s).to eq('10.0.0')
    end
  end

  describe '#==' do
    it 'returns true for versions with the same major, minor, and patch' do
      version1 = Version.new(1, 2, 3)
      version2 = Version.new(1, 2, 3)
      expect(version1 == version2).to be true
    end

    it 'returns true for versions with the same major version (defaults)' do
      version1 = Version.new(1)
      version2 = Version.new(1, 0, 0)
      expect(version1 == version2).to be true
    end

    it 'returns false for versions with different major versions' do
      version1 = Version.new(1)
      version2 = Version.new(2)
      expect(version1 == version2).to be false
    end

    it 'returns false for versions with different minor versions' do
      version1 = Version.new(1, 2)
      version2 = Version.new(1, 3)
      expect(version1 == version2).to be false
    end

    it 'returns false for versions with different patch versions' do
      version1 = Version.new(1, 2, 3)
      version2 = Version.new(1, 2, 4)
      expect(version1 == version2).to be false
    end

    it 'returns false when comparing with non-Version objects' do
      version = Version.new(1)
      expect(version == 1).to be false
      expect(version == '1.0.0').to be false
      expect(version == nil).to be false
    end
  end

  describe '#hash' do
    it 'returns the same hash for versions with the same major, minor, and patch' do
      version1 = Version.new(1, 2, 3)
      version2 = Version.new(1, 2, 3)
      expect(version1.hash).to eq(version2.hash)
    end

    it 'returns the same hash for equivalent versions (with defaults)' do
      version1 = Version.new(1)
      version2 = Version.new(1, 0, 0)
      expect(version1.hash).to eq(version2.hash)
    end

    it 'returns different hashes for versions with different major versions' do
      version1 = Version.new(1)
      version2 = Version.new(2)
      expect(version1.hash).not_to eq(version2.hash)
    end

    it 'returns different hashes for versions with different minor versions' do
      version1 = Version.new(1, 2)
      version2 = Version.new(1, 3)
      expect(version1.hash).not_to eq(version2.hash)
    end

    it 'returns different hashes for versions with different patch versions' do
      version1 = Version.new(1, 2, 3)
      version2 = Version.new(1, 2, 4)
      expect(version1.hash).not_to eq(version2.hash)
    end
  end

  describe '#eql?' do
    it 'returns true for versions with the same major, minor, and patch' do
      version1 = Version.new(1, 2, 3)
      version2 = Version.new(1, 2, 3)
      expect(version1.eql?(version2)).to be true
    end

    it 'returns true for equivalent versions (with defaults)' do
      version1 = Version.new(1)
      version2 = Version.new(1, 0, 0)
      expect(version1.eql?(version2)).to be true
    end

    it 'returns false for versions with different major versions' do
      version1 = Version.new(1)
      version2 = Version.new(2)
      expect(version1.eql?(version2)).to be false
    end

    it 'returns false for versions with different minor versions' do
      version1 = Version.new(1, 2)
      version2 = Version.new(1, 3)
      expect(version1.eql?(version2)).to be false
    end

    it 'returns false for versions with different patch versions' do
      version1 = Version.new(1, 2, 3)
      version2 = Version.new(1, 2, 4)
      expect(version1.eql?(version2)).to be false
    end

    it 'returns false when comparing with non-Version objects' do
      version = Version.new(1)
      expect(version.eql?(1)).to be false
      expect(version.eql?('1.0.0')).to be false
    end
  end

  describe 'Comparable' do
    describe '#<=>' do
      it 'returns 0 when versions are equal' do
        version1 = Version.new(1, 2, 3)
        version2 = Version.new(1, 2, 3)
        expect(version1 <=> version2).to eq(0)
      end

      it 'returns 0 when versions are equivalent (with defaults)' do
        version1 = Version.new(1)
        version2 = Version.new(1, 0, 0)
        expect(version1 <=> version2).to eq(0)
      end

      it 'returns -1 when left version is smaller (major)' do
        version1 = Version.new(1)
        version2 = Version.new(2)
        expect(version1 <=> version2).to eq(-1)
      end

      it 'returns -1 when left version is smaller (minor)' do
        version1 = Version.new(1, 2)
        version2 = Version.new(1, 3)
        expect(version1 <=> version2).to eq(-1)
      end

      it 'returns -1 when left version is smaller (patch)' do
        version1 = Version.new(1, 2, 3)
        version2 = Version.new(1, 2, 4)
        expect(version1 <=> version2).to eq(-1)
      end

      it 'returns 1 when left version is larger (major)' do
        version1 = Version.new(2)
        version2 = Version.new(1)
        expect(version1 <=> version2).to eq(1)
      end

      it 'returns 1 when left version is larger (minor)' do
        version1 = Version.new(1, 3)
        version2 = Version.new(1, 2)
        expect(version1 <=> version2).to eq(1)
      end

      it 'returns 1 when left version is larger (patch)' do
        version1 = Version.new(1, 2, 4)
        version2 = Version.new(1, 2, 3)
        expect(version1 <=> version2).to eq(1)
      end

      it 'prioritizes major over minor and patch' do
        version1 = Version.new(2, 0, 0)
        version2 = Version.new(1, 9, 9)
        expect(version1 <=> version2).to eq(1)
      end

      it 'prioritizes minor over patch when major is same' do
        version1 = Version.new(1, 3, 0)
        version2 = Version.new(1, 2, 9)
        expect(version1 <=> version2).to eq(1)
      end

      it 'returns nil when comparing with non-Version objects' do
        version = Version.new(1)
        expect(version <=> 1).to be_nil
        expect(version <=> '1.0.0').to be_nil
      end
    end

    describe 'comparison operators' do
      let(:version_1_0_0) { Version.new(1, 0, 0) }
      let(:version_1_2_0) { Version.new(1, 2, 0) }
      let(:version_1_2_3) { Version.new(1, 2, 3) }
      let(:version_1_2_4) { Version.new(1, 2, 4) }
      let(:version_2_0_0) { Version.new(2, 0, 0) }
      let(:version_1_0_0_duplicate) { Version.new(1) }

      it 'supports < operator' do
        expect(version_1_0_0 < version_2_0_0).to be true
        expect(version_1_2_0 < version_1_2_3).to be true
        expect(version_1_2_3 < version_1_2_4).to be true
        expect(version_2_0_0 < version_1_0_0).to be false
        expect(version_1_0_0 < version_1_0_0_duplicate).to be false
      end

      it 'supports <= operator' do
        expect(version_1_0_0 <= version_2_0_0).to be true
        expect(version_1_2_0 <= version_1_2_3).to be true
        expect(version_1_2_3 <= version_1_2_4).to be true
        expect(version_1_0_0 <= version_1_0_0_duplicate).to be true
        expect(version_2_0_0 <= version_1_0_0).to be false
      end

      it 'supports > operator' do
        expect(version_2_0_0 > version_1_0_0).to be true
        expect(version_1_2_3 > version_1_2_0).to be true
        expect(version_1_2_4 > version_1_2_3).to be true
        expect(version_1_0_0 > version_2_0_0).to be false
        expect(version_1_0_0 > version_1_0_0_duplicate).to be false
      end

      it 'supports >= operator' do
        expect(version_2_0_0 >= version_1_0_0).to be true
        expect(version_1_2_3 >= version_1_2_0).to be true
        expect(version_1_2_4 >= version_1_2_3).to be true
        expect(version_1_0_0 >= version_1_0_0_duplicate).to be true
        expect(version_1_0_0 >= version_2_0_0).to be false
      end
    end
  end

  describe 'edge cases' do
    it 'works with zero version' do
      version = Version.new(0)
      expect(version.major).to eq(0)
      expect(version.minor).to eq(0)
      expect(version.patch).to eq(0)
      expect(version.to_s).to eq('0.0.0')
    end

    it 'works with negative versions' do
      version = Version.new(-1)
      expect(version.major).to eq(-1)
      expect(version.minor).to eq(0)
      expect(version.patch).to eq(0)
      expect(version.to_s).to eq('-1.0.0')
    end

    it 'works with negative minor and patch' do
      version = Version.new(1, -2, -3)
      expect(version.major).to eq(1)
      expect(version.minor).to eq(-2)
      expect(version.patch).to eq(-3)
      expect(version.to_s).to eq('1.-2.-3')
    end

    it 'can be used as hash keys' do
      hash = {}
      version1 = Version.new(1, 2, 3)
      version2 = Version.new(1, 2, 3)
      version3 = Version.new(2, 0, 0)

      hash[version1] = 'value1'
      hash[version3] = 'value2'

      expect(hash[version2]).to eq('value1')  # same version
      expect(hash[version3]).to eq('value2')
      expect(hash.size).to eq(2)
    end

    it 'handles large version numbers' do
      version = Version.new(999, 888, 777)
      expect(version.to_s).to eq('999.888.777')
    end
  end

  describe 'semantic versioning examples' do
    it 'handles typical semantic versions' do
      versions = [
        Version.new(1, 0, 0),
        Version.new(1, 1, 0),
        Version.new(1, 1, 1),
        Version.new(2, 0, 0)
      ]

      expect(versions.sort.map(&:to_s)).to eq(['1.0.0', '1.1.0', '1.1.1', '2.0.0'])
    end

    it 'correctly orders complex version sequences' do
      v1 = Version.new(1, 0, 0)
      v2 = Version.new(1, 0, 1)
      v3 = Version.new(1, 1, 0)
      v4 = Version.new(2, 0, 0)

      expect(v1 < v2).to be true
      expect(v2 < v3).to be true
      expect(v3 < v4).to be true
    end
  end
end
