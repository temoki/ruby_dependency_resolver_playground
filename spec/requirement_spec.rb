require 'spec_helper'
require_relative '../lib/requirement'
require_relative '../lib/version'

RSpec.describe Requirement do
  let(:version_1) { Version.new(1) }
  let(:version_2) { Version.new(2) }
  let(:version_3) { Version.new(3) }

  describe '#initialize' do
    it 'sets the operator and version' do
      requirement = Requirement.new('>=', version_1)
      expect(requirement.operator).to eq('>=')
      expect(requirement.version).to eq(version_1)
    end

    it 'accepts different operators' do
      operators = ['=', '>', '<', '>=', '<=']
      operators.each do |op|
        requirement = Requirement.new(op, version_1)
        expect(requirement.operator).to eq(op)
        expect(requirement.version).to eq(version_1)
      end
    end
  end

  describe '#to_s' do
    it 'returns operator and version as a string' do
      requirement = Requirement.new('>=', version_1)
      expect(requirement.to_s).to eq('>= 1')
    end

    it 'works with different operators and versions' do
      requirement = Requirement.new('<', version_2)
      expect(requirement.to_s).to eq('< 2')
    end

    it 'handles all supported operators' do
      expectations = {
        '=' => '= 1',
        '>' => '> 1',
        '<' => '< 1',
        '>=' => '>= 1',
        '<=' => '<= 1'
      }

      expectations.each do |operator, expected_string|
        requirement = Requirement.new(operator, version_1)
        expect(requirement.to_s).to eq(expected_string)
      end
    end
  end

  describe '#==' do
    it 'returns true for requirements with same operator and version' do
      req1 = Requirement.new('>=', version_1)
      req2 = Requirement.new('>=', version_1)
      expect(req1 == req2).to be true
    end

    it 'returns false for requirements with different operators' do
      req1 = Requirement.new('>=', version_1)
      req2 = Requirement.new('>', version_1)
      expect(req1 == req2).to be false
    end

    it 'returns false for requirements with different versions' do
      req1 = Requirement.new('>=', version_1)
      req2 = Requirement.new('>=', version_2)
      expect(req1 == req2).to be false
    end

    it 'returns false when comparing with non-Requirement objects' do
      requirement = Requirement.new('>=', version_1)
      expect(requirement == '>= 1').to be false
      expect(requirement == nil).to be false
      expect(requirement == version_1).to be false
    end
  end

  describe '#hash' do
    it 'returns the same hash for requirements with same operator and version' do
      req1 = Requirement.new('>=', version_1)
      req2 = Requirement.new('>=', version_1)
      expect(req1.hash).to eq(req2.hash)
    end

    it 'returns different hashes for requirements with different operators' do
      req1 = Requirement.new('>=', version_1)
      req2 = Requirement.new('>', version_1)
      expect(req1.hash).not_to eq(req2.hash)
    end

    it 'returns different hashes for requirements with different versions' do
      req1 = Requirement.new('>=', version_1)
      req2 = Requirement.new('>=', version_2)
      expect(req1.hash).not_to eq(req2.hash)
    end
  end

  describe '#eql?' do
    it 'returns true for requirements with same operator and version' do
      req1 = Requirement.new('>=', version_1)
      req2 = Requirement.new('>=', version_1)
      expect(req1.eql?(req2)).to be true
    end

    it 'returns false for requirements with different operators' do
      req1 = Requirement.new('>=', version_1)
      req2 = Requirement.new('>', version_1)
      expect(req1.eql?(req2)).to be false
    end

    it 'returns false for requirements with different versions' do
      req1 = Requirement.new('>=', version_1)
      req2 = Requirement.new('>=', version_2)
      expect(req1.eql?(req2)).to be false
    end

    it 'returns false when comparing with non-Requirement objects' do
      requirement = Requirement.new('>=', version_1)
      expect(requirement.eql?('>= 1')).to be false
    end
  end

  describe '#satisfied_by?' do
    describe 'with = operator' do
      let(:requirement) { Requirement.new('=', version_2) }

      it 'returns true when version matches exactly' do
        expect(requirement.satisfied_by?(version_2)).to be true
      end

      it 'returns false when version is different' do
        expect(requirement.satisfied_by?(version_1)).to be false
        expect(requirement.satisfied_by?(version_3)).to be false
      end
    end

    describe 'with > operator' do
      let(:requirement) { Requirement.new('>', version_2) }

      it 'returns true when version is greater' do
        expect(requirement.satisfied_by?(version_3)).to be true
      end

      it 'returns false when version is equal' do
        expect(requirement.satisfied_by?(version_2)).to be false
      end

      it 'returns false when version is smaller' do
        expect(requirement.satisfied_by?(version_1)).to be false
      end
    end

    describe 'with < operator' do
      let(:requirement) { Requirement.new('<', version_2) }

      it 'returns true when version is smaller' do
        expect(requirement.satisfied_by?(version_1)).to be true
      end

      it 'returns false when version is equal' do
        expect(requirement.satisfied_by?(version_2)).to be false
      end

      it 'returns false when version is greater' do
        expect(requirement.satisfied_by?(version_3)).to be false
      end
    end

    describe 'with >= operator' do
      let(:requirement) { Requirement.new('>=', version_2) }

      it 'returns true when version is greater' do
        expect(requirement.satisfied_by?(version_3)).to be true
      end

      it 'returns true when version is equal' do
        expect(requirement.satisfied_by?(version_2)).to be true
      end

      it 'returns false when version is smaller' do
        expect(requirement.satisfied_by?(version_1)).to be false
      end
    end

    describe 'with <= operator' do
      let(:requirement) { Requirement.new('<=', version_2) }

      it 'returns true when version is smaller' do
        expect(requirement.satisfied_by?(version_1)).to be true
      end

      it 'returns true when version is equal' do
        expect(requirement.satisfied_by?(version_2)).to be true
      end

      it 'returns false when version is greater' do
        expect(requirement.satisfied_by?(version_3)).to be false
      end
    end

    describe 'with unsupported operator' do
      let(:requirement) { Requirement.new('~>', version_2) }

      it 'returns false for any version' do
        expect(requirement.satisfied_by?(version_1)).to be false
        expect(requirement.satisfied_by?(version_2)).to be false
        expect(requirement.satisfied_by?(version_3)).to be false
      end
    end
  end

  describe 'edge cases' do
    it 'works with zero version' do
      zero_version = Version.new(0)
      requirement = Requirement.new('>=', zero_version)
      expect(requirement.version).to eq(zero_version)
      expect(requirement.satisfied_by?(version_1)).to be true
      expect(requirement.satisfied_by?(zero_version)).to be true
    end

    it 'works with negative versions' do
      negative_version = Version.new(-1)
      requirement = Requirement.new('>', negative_version)
      expect(requirement.version).to eq(negative_version)
      expect(requirement.satisfied_by?(Version.new(0))).to be true
      expect(requirement.satisfied_by?(negative_version)).to be false
    end

    it 'can be used as hash keys' do
      hash = {}
      req1 = Requirement.new('>=', version_1)
      req2 = Requirement.new('>=', version_1)  # same as req1
      req3 = Requirement.new('>', version_1)   # different operator

      hash[req1] = 'value1'
      hash[req3] = 'value2'

      expect(hash[req2]).to eq('value1')  # same requirement
      expect(hash[req3]).to eq('value2')
      expect(hash.size).to eq(2)
    end

    it 'handles string operators correctly' do
      requirement = Requirement.new('>=', version_1)
      expect(requirement.operator).to be_a(String)
      expect(requirement.operator).to eq('>=')
    end
  end

  describe 'comprehensive satisfaction matrix' do
    let(:versions) { [Version.new(1), Version.new(2), Version.new(3)] }
    let(:operators) { ['=', '>', '<', '>=', '<='] }

    it 'satisfies expected combinations' do
      # Test version 2 with various operators against different target versions
      test_cases = [
        # [operator, requirement_version, test_version, expected_result]
        ['=', 2, 1, false],
        ['=', 2, 2, true],
        ['=', 2, 3, false],
        
        ['>', 2, 1, false],
        ['>', 2, 2, false],
        ['>', 2, 3, true],
        
        ['<', 2, 1, true],
        ['<', 2, 2, false],
        ['<', 2, 3, false],
        
        ['>=', 2, 1, false],
        ['>=', 2, 2, true],
        ['>=', 2, 3, true],
        
        ['<=', 2, 1, true],
        ['<=', 2, 2, true],
        ['<=', 2, 3, false]
      ]

      test_cases.each do |operator, req_version, test_version, expected|
        requirement = Requirement.new(operator, Version.new(req_version))
        version_to_test = Version.new(test_version)
        result = requirement.satisfied_by?(version_to_test)
        
        expect(result).to eq(expected), 
          "Expected #{operator} #{req_version} satisfied by #{test_version} to be #{expected}, got #{result}"
      end
    end
  end
end
