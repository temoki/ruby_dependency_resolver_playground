require 'spec_helper'
require_relative '../lib/dependency'
require_relative '../lib/requirement'
require_relative '../lib/version'
require_relative '../lib/specification'

RSpec.describe Dependency do
  let(:version_1) { Version.new(1) }
  let(:version_2) { Version.new(2) }
  let(:version_3) { Version.new(3) }
  
  let(:requirement_gte_1) { Requirement.new('>=', version_1) }
  let(:requirement_eq_2) { Requirement.new('=', version_2) }
  let(:requirement_lt_3) { Requirement.new('<', version_3) }

  describe '#initialize' do
    it 'sets the name and requirement' do
      dependency = Dependency.new('gem_a', requirement_gte_1)
      expect(dependency.name).to eq('gem_a')
      expect(dependency.requirement).to eq(requirement_gte_1)
    end

    it 'accepts different names and requirements' do
      dependency = Dependency.new('another_gem', requirement_eq_2)
      expect(dependency.name).to eq('another_gem')
      expect(dependency.requirement).to eq(requirement_eq_2)
    end

    it 'works with complex gem names' do
      complex_names = ['gem-with-dashes', 'gem_with_underscores', 'GemWithCamelCase', 'gem123']
      complex_names.each do |name|
        dependency = Dependency.new(name, requirement_gte_1)
        expect(dependency.name).to eq(name)
        expect(dependency.requirement).to eq(requirement_gte_1)
      end
    end
  end

  describe '#to_s' do
    it 'returns name and requirement in parentheses' do
      dependency = Dependency.new('gem_a', requirement_gte_1)
      expect(dependency.to_s).to eq('gem_a (>= 1.0.0)')
    end

    it 'works with different names and requirements' do
      dependency = Dependency.new('my_gem', requirement_eq_2)
      expect(dependency.to_s).to eq('my_gem (= 2.0.0)')
    end

    it 'formats correctly with all operator types' do
      operators_and_expectations = {
        Requirement.new('=', version_1) => 'test_gem (= 1.0.0)',
        Requirement.new('!=', version_1) => 'test_gem (!= 1.0.0)',
        Requirement.new('>', version_1) => 'test_gem (> 1.0.0)',
        Requirement.new('<', version_1) => 'test_gem (< 1.0.0)',
        Requirement.new('>=', version_1) => 'test_gem (>= 1.0.0)',
        Requirement.new('<=', version_1) => 'test_gem (<= 1.0.0)',
        Requirement.new('~>', version_1) => 'test_gem (~> 1.0.0)'
      }

      operators_and_expectations.each do |requirement, expected_string|
        dependency = Dependency.new('test_gem', requirement)
        expect(dependency.to_s).to eq(expected_string)
      end
    end
  end

  describe '#==' do
    it 'returns true for dependencies with same name and requirement' do
      dep1 = Dependency.new('gem_a', requirement_gte_1)
      dep2 = Dependency.new('gem_a', requirement_gte_1)
      expect(dep1 == dep2).to be true
    end

    it 'returns false for dependencies with different names' do
      dep1 = Dependency.new('gem_a', requirement_gte_1)
      dep2 = Dependency.new('gem_b', requirement_gte_1)
      expect(dep1 == dep2).to be false
    end

    it 'returns false for dependencies with different requirements' do
      dep1 = Dependency.new('gem_a', requirement_gte_1)
      dep2 = Dependency.new('gem_a', requirement_eq_2)
      expect(dep1 == dep2).to be false
    end

    it 'returns false for dependencies with both different names and requirements' do
      dep1 = Dependency.new('gem_a', requirement_gte_1)
      dep2 = Dependency.new('gem_b', requirement_eq_2)
      expect(dep1 == dep2).to be false
    end

    it 'returns false when comparing with non-Dependency objects' do
      dependency = Dependency.new('gem_a', requirement_gte_1)
      expect(dependency == 'gem_a (>= 1)').to be false
      expect(dependency == nil).to be false
      expect(dependency == requirement_gte_1).to be false
      expect(dependency == 'gem_a').to be false
    end

    it 'is case sensitive for gem names' do
      dep1 = Dependency.new('Gem_A', requirement_gte_1)
      dep2 = Dependency.new('gem_a', requirement_gte_1)
      expect(dep1 == dep2).to be false
    end
  end

  describe '#hash' do
    it 'returns the same hash for dependencies with same name and requirement' do
      dep1 = Dependency.new('gem_a', requirement_gte_1)
      dep2 = Dependency.new('gem_a', requirement_gte_1)
      expect(dep1.hash).to eq(dep2.hash)
    end

    it 'returns different hashes for dependencies with different names' do
      dep1 = Dependency.new('gem_a', requirement_gte_1)
      dep2 = Dependency.new('gem_b', requirement_gte_1)
      expect(dep1.hash).not_to eq(dep2.hash)
    end

    it 'returns different hashes for dependencies with different requirements' do
      dep1 = Dependency.new('gem_a', requirement_gte_1)
      dep2 = Dependency.new('gem_a', requirement_eq_2)
      expect(dep1.hash).not_to eq(dep2.hash)
    end

    it 'returns different hashes for dependencies with both different names and requirements' do
      dep1 = Dependency.new('gem_a', requirement_gte_1)
      dep2 = Dependency.new('gem_b', requirement_eq_2)
      expect(dep1.hash).not_to eq(dep2.hash)
    end
  end

  describe '#eql?' do
    it 'returns true for dependencies with same name and requirement' do
      dep1 = Dependency.new('gem_a', requirement_gte_1)
      dep2 = Dependency.new('gem_a', requirement_gte_1)
      expect(dep1.eql?(dep2)).to be true
    end

    it 'returns false for dependencies with different names' do
      dep1 = Dependency.new('gem_a', requirement_gte_1)
      dep2 = Dependency.new('gem_b', requirement_gte_1)
      expect(dep1.eql?(dep2)).to be false
    end

    it 'returns false for dependencies with different requirements' do
      dep1 = Dependency.new('gem_a', requirement_gte_1)
      dep2 = Dependency.new('gem_a', requirement_eq_2)
      expect(dep1.eql?(dep2)).to be false
    end

    it 'returns false when comparing with non-Dependency objects' do
      dependency = Dependency.new('gem_a', requirement_gte_1)
      expect(dependency.eql?('gem_a (>= 1)')).to be false
      expect(dependency.eql?(nil)).to be false
    end
  end

  describe 'edge cases' do
    it 'works with empty string name' do
      dependency = Dependency.new('', requirement_gte_1)
      expect(dependency.name).to eq('')
      expect(dependency.requirement).to eq(requirement_gte_1)
      expect(dependency.to_s).to eq(' (>= 1.0.0)')
    end

    it 'works with names containing special characters' do
      special_names = ['gem@1.0', 'gem+plus', 'gem-with-dots.rb', 'gem/with/slashes']
      special_names.each do |name|
        dependency = Dependency.new(name, requirement_gte_1)
        expect(dependency.name).to eq(name)
        expect(dependency.to_s).to eq("#{name} (>= 1.0.0)")
      end
    end

    it 'works with very long names' do
      long_name = 'a' * 1000
      dependency = Dependency.new(long_name, requirement_gte_1)
      expect(dependency.name).to eq(long_name)
      expect(dependency.to_s).to eq("#{long_name} (>= 1.0.0)")
    end

    it 'can be used as hash keys' do
      hash = {}
      dep1 = Dependency.new('gem_a', requirement_gte_1)
      dep2 = Dependency.new('gem_a', requirement_gte_1)  # same as dep1
      dep3 = Dependency.new('gem_b', requirement_gte_1)  # different name
      dep4 = Dependency.new('gem_a', requirement_eq_2)   # different requirement

      hash[dep1] = 'value1'
      hash[dep3] = 'value2'
      hash[dep4] = 'value3'

      expect(hash[dep2]).to eq('value1')  # same dependency
      expect(hash[dep3]).to eq('value2')
      expect(hash[dep4]).to eq('value3')
      expect(hash.size).to eq(3)
    end

    it 'handles nil requirement gracefully' do
      # Note: This might not be a valid use case in real scenarios,
      # but testing the behavior for completeness
      dependency = Dependency.new('gem_a', nil)
      expect(dependency.name).to eq('gem_a')
      expect(dependency.requirement).to be_nil
      expect(dependency.to_s).to eq('gem_a ()')
    end
  end

  describe 'integration with Requirement class' do
    it 'correctly stores and retrieves requirement objects' do
      requirement = Requirement.new('>=', Version.new(5))
      dependency = Dependency.new('integration_gem', requirement)
      
      expect(dependency.requirement).to be_a(Requirement)
      expect(dependency.requirement.operator).to eq('>=')
      expect(dependency.requirement.version.major).to eq(5)
      expect(dependency.to_s).to eq('integration_gem (>= 5.0.0)')
    end

    it 'works with various requirement configurations' do
      test_cases = [
        ['activerecord', Requirement.new('~>', Version.new(6))],
        ['rails', Requirement.new('=', Version.new(7))],
        ['rspec', Requirement.new('>=', Version.new(3))],
        ['nokogiri', Requirement.new('<', Version.new(2))],
        ['json', Requirement.new('<=', Version.new(1))]
      ]

      test_cases.each do |name, requirement|
        dependency = Dependency.new(name, requirement)
        expect(dependency.name).to eq(name)
        expect(dependency.requirement).to eq(requirement)
        
        # Verify the string representation includes both name and requirement
        string_repr = dependency.to_s
        expect(string_repr).to include(name)
        expect(string_repr).to include(requirement.to_s)
        expect(string_repr).to match(/#{Regexp.escape(name)} \(#{Regexp.escape(requirement.to_s)}\)/)
      end
    end
  end

  describe 'comparison scenarios' do
    it 'distinguishes between same gem with different version requirements' do
      gem_v1 = Dependency.new('my_gem', Requirement.new('=', Version.new(1)))
      gem_v2 = Dependency.new('my_gem', Requirement.new('=', Version.new(2)))
      gem_gte1 = Dependency.new('my_gem', Requirement.new('>=', Version.new(1)))

      # All should be different
      expect(gem_v1).not_to eq(gem_v2)
      expect(gem_v1).not_to eq(gem_gte1)
      expect(gem_v2).not_to eq(gem_gte1)

      # Hash values should be different
      expect(gem_v1.hash).not_to eq(gem_v2.hash)
      expect(gem_v1.hash).not_to eq(gem_gte1.hash)
      expect(gem_v2.hash).not_to eq(gem_gte1.hash)
    end

    it 'treats same name and requirement as identical' do
      dep1 = Dependency.new('identical_gem', Requirement.new('>=', Version.new(2)))
      dep2 = Dependency.new('identical_gem', Requirement.new('>=', Version.new(2)))

      expect(dep1).to eq(dep2)
      expect(dep1.hash).to eq(dep2.hash)
      expect(dep1.eql?(dep2)).to be true
      expect(dep1.to_s).to eq(dep2.to_s)
    end
  end

  describe '#satisfied_by?' do
    let(:specification_gem_a_v1) { Specification.new('gem_a', version_1, []) }
    let(:specification_gem_a_v2) { Specification.new('gem_a', version_2, []) }
    let(:specification_gem_a_v3) { Specification.new('gem_a', version_3, []) }
    let(:specification_gem_b_v2) { Specification.new('gem_b', version_2, []) }

    context 'when names match' do
      it 'returns true when requirement is satisfied' do
        # gem_a >= 1 is satisfied by gem_a v2
        dependency = Dependency.new('gem_a', requirement_gte_1)
        expect(dependency.satisfied_by?(specification_gem_a_v2)).to be true
        expect(dependency.satisfied_by?(specification_gem_a_v1)).to be true
        expect(dependency.satisfied_by?(specification_gem_a_v3)).to be true
      end

      it 'returns false when requirement is not satisfied' do
        # gem_a = 2 is not satisfied by gem_a v1 or v3
        dependency = Dependency.new('gem_a', requirement_eq_2)
        expect(dependency.satisfied_by?(specification_gem_a_v1)).to be false
        expect(dependency.satisfied_by?(specification_gem_a_v3)).to be false
        expect(dependency.satisfied_by?(specification_gem_a_v2)).to be true
      end

      it 'works with less than requirement' do
        # gem_a < 3 is satisfied by gem_a v1 and v2 but not v3
        dependency = Dependency.new('gem_a', requirement_lt_3)
        expect(dependency.satisfied_by?(specification_gem_a_v1)).to be true
        expect(dependency.satisfied_by?(specification_gem_a_v2)).to be true
        expect(dependency.satisfied_by?(specification_gem_a_v3)).to be false
      end
    end

    context 'when names do not match' do
      it 'returns false even if version requirement would be satisfied' do
        # gem_a >= 1 vs gem_b v2 - names don't match
        dependency = Dependency.new('gem_a', requirement_gte_1)
        expect(dependency.satisfied_by?(specification_gem_b_v2)).to be false
      end

      it 'returns false for exact version match with different names' do
        # gem_a = 2 vs gem_b v2 - names don't match
        dependency = Dependency.new('gem_a', requirement_eq_2)
        expect(dependency.satisfied_by?(specification_gem_b_v2)).to be false
      end
    end

    context 'with invalid arguments' do
      it 'returns false for nil argument' do
        dependency = Dependency.new('gem_a', requirement_gte_1)
        expect(dependency.satisfied_by?(nil)).to be false
      end

      it 'returns false for non-Specification objects' do
        dependency = Dependency.new('gem_a', requirement_gte_1)
        expect(dependency.satisfied_by?('string')).to be false
        expect(dependency.satisfied_by?(123)).to be false
        expect(dependency.satisfied_by?(version_1)).to be false
        expect(dependency.satisfied_by?(requirement_gte_1)).to be false
      end
    end

    context 'with various operators' do
      let(:requirement_gt_1) { Requirement.new('>', version_1) }
      let(:requirement_lte_2) { Requirement.new('<=', version_2) }
      let(:requirement_ne_2) { Requirement.new('!=', version_2) }
      let(:requirement_pessimistic_1_4) { Requirement.new('~>', Version.new(1, 4, 0)) }

      it 'works correctly with greater than operator' do
        dependency = Dependency.new('gem_a', requirement_gt_1)
        expect(dependency.satisfied_by?(specification_gem_a_v1)).to be false  # 1 > 1 is false
        expect(dependency.satisfied_by?(specification_gem_a_v2)).to be true   # 2 > 1 is true
        expect(dependency.satisfied_by?(specification_gem_a_v3)).to be true   # 3 > 1 is true
      end

      it 'works correctly with less than or equal operator' do
        dependency = Dependency.new('gem_a', requirement_lte_2)
        expect(dependency.satisfied_by?(specification_gem_a_v1)).to be true   # 1 <= 2 is true
        expect(dependency.satisfied_by?(specification_gem_a_v2)).to be true   # 2 <= 2 is true
        expect(dependency.satisfied_by?(specification_gem_a_v3)).to be false  # 3 <= 2 is false
      end

      it 'works correctly with not equal operator' do
        dependency = Dependency.new('gem_a', requirement_ne_2)
        expect(dependency.satisfied_by?(specification_gem_a_v1)).to be true   # 1 != 2 is true
        expect(dependency.satisfied_by?(specification_gem_a_v2)).to be false  # 2 != 2 is false
        expect(dependency.satisfied_by?(specification_gem_a_v3)).to be true   # 3 != 2 is true
      end

      it 'works correctly with pessimistic operator' do
        dependency = Dependency.new('gem_a', requirement_pessimistic_1_4)
        spec_1_4_0 = Specification.new('gem_a', Version.new(1, 4, 0), [])
        spec_1_5_2 = Specification.new('gem_a', Version.new(1, 5, 2), [])
        spec_2_0_0 = Specification.new('gem_a', Version.new(2, 0, 0), [])
        spec_1_3_9 = Specification.new('gem_a', Version.new(1, 3, 9), [])
        
        expect(dependency.satisfied_by?(spec_1_4_0)).to be true   # ~> 1.4.0 satisfied by 1.4.0
        expect(dependency.satisfied_by?(spec_1_5_2)).to be true   # ~> 1.4.0 satisfied by 1.5.2
        expect(dependency.satisfied_by?(spec_2_0_0)).to be false  # ~> 1.4.0 not satisfied by 2.0.0
        expect(dependency.satisfied_by?(spec_1_3_9)).to be false  # ~> 1.4.0 not satisfied by 1.3.9
      end
    end

    context 'edge cases' do
      it 'handles specifications with dependencies' do
        dep_a = Dependency.new('gem_c', requirement_gte_1)
        dep_b = Dependency.new('gem_d', requirement_eq_2)
        spec_with_deps = Specification.new('gem_a', version_2, [dep_a, dep_b])
        dependency = Dependency.new('gem_a', requirement_eq_2)
        expect(dependency.satisfied_by?(spec_with_deps)).to be true
      end

      it 'is case sensitive for gem names' do
        spec_uppercase = Specification.new('GEM_A', version_2, [])
        dependency_lowercase = Dependency.new('gem_a', requirement_eq_2)
        expect(dependency_lowercase.satisfied_by?(spec_uppercase)).to be false
      end

      it 'handles empty gem names' do
        spec_empty_name = Specification.new('', version_1, [])
        dependency_empty_name = Dependency.new('', requirement_gte_1)
        dependency_normal_name = Dependency.new('gem_a', requirement_gte_1)
        
        expect(dependency_empty_name.satisfied_by?(spec_empty_name)).to be true
        expect(dependency_normal_name.satisfied_by?(spec_empty_name)).to be false
      end
    end
  end
end
