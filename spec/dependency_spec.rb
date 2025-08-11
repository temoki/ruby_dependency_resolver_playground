require 'spec_helper'
require_relative '../lib/dependency'
require_relative '../lib/requirement'
require_relative '../lib/version'

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
      expect(dependency.to_s).to eq('gem_a (>= 1)')
    end

    it 'works with different names and requirements' do
      dependency = Dependency.new('my_gem', requirement_eq_2)
      expect(dependency.to_s).to eq('my_gem (= 2)')
    end

    it 'formats correctly with all operator types' do
      operators_and_expectations = {
        Requirement.new('=', version_1) => 'test_gem (= 1)',
        Requirement.new('>', version_1) => 'test_gem (> 1)',
        Requirement.new('<', version_1) => 'test_gem (< 1)',
        Requirement.new('>=', version_1) => 'test_gem (>= 1)',
        Requirement.new('<=', version_1) => 'test_gem (<= 1)'
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
      expect(dependency.to_s).to eq(' (>= 1)')
    end

    it 'works with names containing special characters' do
      special_names = ['gem@1.0', 'gem+plus', 'gem-with-dots.rb', 'gem/with/slashes']
      special_names.each do |name|
        dependency = Dependency.new(name, requirement_gte_1)
        expect(dependency.name).to eq(name)
        expect(dependency.to_s).to eq("#{name} (>= 1)")
      end
    end

    it 'works with very long names' do
      long_name = 'a' * 1000
      dependency = Dependency.new(long_name, requirement_gte_1)
      expect(dependency.name).to eq(long_name)
      expect(dependency.to_s).to eq("#{long_name} (>= 1)")
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
      expect(dependency.to_s).to eq('integration_gem (>= 5)')
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
end
