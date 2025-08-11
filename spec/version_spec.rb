require 'spec_helper'
require_relative '../lib/version'

RSpec.describe Version do
  describe '#initialize' do
    it 'sets the major version' do
      version = Version.new(1)
      expect(version.major).to eq(1)
    end

    it 'accepts different major versions' do
      version = Version.new(5)
      expect(version.major).to eq(5)
    end
  end

  describe '#to_s' do
    it 'returns the major version as a string' do
      version = Version.new(2)
      expect(version.to_s).to eq('2')
    end

    it 'works with different major versions' do
      version = Version.new(10)
      expect(version.to_s).to eq('10')
    end
  end

  describe '#==' do
    it 'returns true for versions with the same major version' do
      version1 = Version.new(1)
      version2 = Version.new(1)
      expect(version1 == version2).to be true
    end

    it 'returns false for versions with different major versions' do
      version1 = Version.new(1)
      version2 = Version.new(2)
      expect(version1 == version2).to be false
    end

    it 'returns false when comparing with non-Version objects' do
      version = Version.new(1)
      expect(version == 1).to be false
      expect(version == '1').to be false
      expect(version == nil).to be false
    end
  end

  describe '#hash' do
    it 'returns the same hash for versions with the same major version' do
      version1 = Version.new(1)
      version2 = Version.new(1)
      expect(version1.hash).to eq(version2.hash)
    end

    it 'returns different hashes for versions with different major versions' do
      version1 = Version.new(1)
      version2 = Version.new(2)
      expect(version1.hash).not_to eq(version2.hash)
    end
  end

  describe '#eql?' do
    it 'returns true for versions with the same major version' do
      version1 = Version.new(1)
      version2 = Version.new(1)
      expect(version1.eql?(version2)).to be true
    end

    it 'returns false for versions with different major versions' do
      version1 = Version.new(1)
      version2 = Version.new(2)
      expect(version1.eql?(version2)).to be false
    end

    it 'returns false when comparing with non-Version objects' do
      version = Version.new(1)
      expect(version.eql?(1)).to be false
    end
  end

  describe 'Comparable' do
    describe '#<=>' do
      it 'returns 0 when versions are equal' do
        version1 = Version.new(1)
        version2 = Version.new(1)
        expect(version1 <=> version2).to eq(0)
      end

      it 'returns -1 when left version is smaller' do
        version1 = Version.new(1)
        version2 = Version.new(2)
        expect(version1 <=> version2).to eq(-1)
      end

      it 'returns 1 when left version is larger' do
        version1 = Version.new(2)
        version2 = Version.new(1)
        expect(version1 <=> version2).to eq(1)
      end

      it 'returns nil when comparing with non-Version objects' do
        version = Version.new(1)
        expect(version <=> 1).to be_nil
        expect(version <=> '1').to be_nil
      end
    end

    describe 'comparison operators' do
      let(:version_1) { Version.new(1) }
      let(:version_2) { Version.new(2) }
      let(:version_1_duplicate) { Version.new(1) }

      it 'supports < operator' do
        expect(version_1 < version_2).to be true
        expect(version_2 < version_1).to be false
        expect(version_1 < version_1_duplicate).to be false
      end

      it 'supports <= operator' do
        expect(version_1 <= version_2).to be true
        expect(version_2 <= version_1).to be false
        expect(version_1 <= version_1_duplicate).to be true
      end

      it 'supports > operator' do
        expect(version_2 > version_1).to be true
        expect(version_1 > version_2).to be false
        expect(version_1 > version_1_duplicate).to be false
      end

      it 'supports >= operator' do
        expect(version_2 >= version_1).to be true
        expect(version_1 >= version_2).to be false
        expect(version_1 >= version_1_duplicate).to be true
      end
    end
  end

  describe 'edge cases' do
    it 'works with zero version' do
      version = Version.new(0)
      expect(version.major).to eq(0)
      expect(version.to_s).to eq('0')
    end

    it 'works with negative versions' do
      version = Version.new(-1)
      expect(version.major).to eq(-1)
      expect(version.to_s).to eq('-1')
    end

    it 'can be used as hash keys' do
      hash = {}
      version1 = Version.new(1)
      version2 = Version.new(1)
      version3 = Version.new(2)

      hash[version1] = 'value1'
      hash[version3] = 'value2'

      expect(hash[version2]).to eq('value1')  # same major version
      expect(hash[version3]).to eq('value2')
      expect(hash.size).to eq(2)
    end
  end
end
