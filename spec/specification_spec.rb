require 'spec_helper'
require_relative '../lib/specification'
require_relative '../lib/dependency'
require_relative '../lib/requirement'
require_relative '../lib/version'

RSpec.describe Specification do
  let(:version_1) { Version.new(1) }
  let(:version_2) { Version.new(2) }
  let(:version_3) { Version.new(3) }
  
  let(:requirement_gte_1) { Requirement.new('>=', version_1) }
  let(:requirement_eq_2) { Requirement.new('=', version_2) }
  let(:requirement_lt_3) { Requirement.new('<', version_3) }
  
  let(:dependency_a) { Dependency.new('gem_a', requirement_gte_1) }
  let(:dependency_b) { Dependency.new('gem_b', requirement_eq_2) }
  let(:dependency_c) { Dependency.new('gem_c', requirement_lt_3) }
  
  let(:empty_dependencies) { [] }
  let(:single_dependency) { [dependency_a] }
  let(:multiple_dependencies) { [dependency_a, dependency_b, dependency_c] }

  describe '#initialize' do
    it 'sets the name, version, and dependencies' do
      spec = Specification.new('my_gem', version_1, single_dependency)
      expect(spec.name).to eq('my_gem')
      expect(spec.version).to eq(version_1)
      expect(spec.dependencies).to eq(single_dependency)
    end

    it 'accepts empty dependencies' do
      spec = Specification.new('my_gem', version_1, empty_dependencies)
      expect(spec.name).to eq('my_gem')
      expect(spec.version).to eq(version_1)
      expect(spec.dependencies).to eq(empty_dependencies)
      expect(spec.dependencies).to be_empty
    end

    it 'accepts multiple dependencies' do
      spec = Specification.new('complex_gem', version_2, multiple_dependencies)
      expect(spec.name).to eq('complex_gem')
      expect(spec.version).to eq(version_2)
      expect(spec.dependencies).to eq(multiple_dependencies)
      expect(spec.dependencies.size).to eq(3)
    end

    it 'stores dependencies as provided (no copying)' do
      deps = [dependency_a]
      spec = Specification.new('my_gem', version_1, deps)
      expect(spec.dependencies).to be(deps)  # same object reference
    end
  end

  describe '#to_s' do
    it 'returns name and version separated by space' do
      spec = Specification.new('my_gem', version_1, empty_dependencies)
      expect(spec.to_s).to eq('my_gem 1.0.0')
    end

    it 'works with different names and versions' do
      spec = Specification.new('another_gem', version_2, single_dependency)
      expect(spec.to_s).to eq('another_gem 2.0.0')
    end

    it 'ignores dependencies in string representation' do
      spec_empty = Specification.new('test_gem', version_1, empty_dependencies)
      spec_with_deps = Specification.new('test_gem', version_1, multiple_dependencies)
      
      expect(spec_empty.to_s).to eq(spec_with_deps.to_s)
      expect(spec_with_deps.to_s).to eq('test_gem 1.0.0')
    end

    it 'handles complex gem names' do
      complex_names = ['gem-with-dashes', 'gem_with_underscores', 'GemWithCamelCase', 'gem123']
      complex_names.each do |name|
        spec = Specification.new(name, version_1, empty_dependencies)
        expect(spec.to_s).to eq("#{name} 1.0.0")
      end
    end
  end

  describe '#==' do
    it 'returns true for specifications with same name and version' do
      spec1 = Specification.new('my_gem', version_1, single_dependency)
      spec2 = Specification.new('my_gem', version_1, multiple_dependencies)
      expect(spec1 == spec2).to be true
    end

    it 'returns false for specifications with different names' do
      spec1 = Specification.new('gem_a', version_1, single_dependency)
      spec2 = Specification.new('gem_b', version_1, single_dependency)
      expect(spec1 == spec2).to be false
    end

    it 'returns false for specifications with different versions' do
      spec1 = Specification.new('my_gem', version_1, single_dependency)
      spec2 = Specification.new('my_gem', version_2, single_dependency)
      expect(spec1 == spec2).to be false
    end

    it 'returns false for specifications with both different names and versions' do
      spec1 = Specification.new('gem_a', version_1, single_dependency)
      spec2 = Specification.new('gem_b', version_2, single_dependency)
      expect(spec1 == spec2).to be false
    end

    it 'ignores dependencies in equality comparison' do
      spec1 = Specification.new('my_gem', version_1, empty_dependencies)
      spec2 = Specification.new('my_gem', version_1, single_dependency)
      spec3 = Specification.new('my_gem', version_1, multiple_dependencies)
      
      expect(spec1 == spec2).to be true
      expect(spec2 == spec3).to be true
      expect(spec1 == spec3).to be true
    end

    it 'returns false when comparing with non-Specification objects' do
      spec = Specification.new('my_gem', version_1, single_dependency)
      expect(spec == 'my_gem 1').to be false
      expect(spec == nil).to be false
      expect(spec == version_1).to be false
      expect(spec == dependency_a).to be false
    end

    it 'is case sensitive for gem names' do
      spec1 = Specification.new('My_Gem', version_1, empty_dependencies)
      spec2 = Specification.new('my_gem', version_1, empty_dependencies)
      expect(spec1 == spec2).to be false
    end
  end

  describe '#hash' do
    it 'returns the same hash for specifications with same name and version' do
      spec1 = Specification.new('my_gem', version_1, single_dependency)
      spec2 = Specification.new('my_gem', version_1, multiple_dependencies)
      expect(spec1.hash).to eq(spec2.hash)
    end

    it 'returns different hashes for specifications with different names' do
      spec1 = Specification.new('gem_a', version_1, single_dependency)
      spec2 = Specification.new('gem_b', version_1, single_dependency)
      expect(spec1.hash).not_to eq(spec2.hash)
    end

    it 'returns different hashes for specifications with different versions' do
      spec1 = Specification.new('my_gem', version_1, single_dependency)
      spec2 = Specification.new('my_gem', version_2, single_dependency)
      expect(spec1.hash).not_to eq(spec2.hash)
    end

    it 'ignores dependencies in hash calculation' do
      spec1 = Specification.new('my_gem', version_1, empty_dependencies)
      spec2 = Specification.new('my_gem', version_1, single_dependency)
      spec3 = Specification.new('my_gem', version_1, multiple_dependencies)
      
      expect(spec1.hash).to eq(spec2.hash)
      expect(spec2.hash).to eq(spec3.hash)
      expect(spec1.hash).to eq(spec3.hash)
    end
  end

  describe '#eql?' do
    it 'returns true for specifications with same name and version' do
      spec1 = Specification.new('my_gem', version_1, single_dependency)
      spec2 = Specification.new('my_gem', version_1, multiple_dependencies)
      expect(spec1.eql?(spec2)).to be true
    end

    it 'returns false for specifications with different names' do
      spec1 = Specification.new('gem_a', version_1, single_dependency)
      spec2 = Specification.new('gem_b', version_1, single_dependency)
      expect(spec1.eql?(spec2)).to be false
    end

    it 'returns false for specifications with different versions' do
      spec1 = Specification.new('my_gem', version_1, single_dependency)
      spec2 = Specification.new('my_gem', version_2, single_dependency)
      expect(spec1.eql?(spec2)).to be false
    end

    it 'ignores dependencies in eql? comparison' do
      spec1 = Specification.new('my_gem', version_1, empty_dependencies)
      spec2 = Specification.new('my_gem', version_1, multiple_dependencies)
      expect(spec1.eql?(spec2)).to be true
    end

    it 'returns false when comparing with non-Specification objects' do
      spec = Specification.new('my_gem', version_1, single_dependency)
      expect(spec.eql?('my_gem 1')).to be false
      expect(spec.eql?(nil)).to be false
    end
  end

  describe 'dependencies management' do
    it 'preserves the order of dependencies' do
      deps = [dependency_c, dependency_a, dependency_b]
      spec = Specification.new('my_gem', version_1, deps)
      expect(spec.dependencies).to eq([dependency_c, dependency_a, dependency_b])
    end

    it 'allows duplicate dependencies' do
      deps = [dependency_a, dependency_a, dependency_b]
      spec = Specification.new('my_gem', version_1, deps)
      expect(spec.dependencies).to eq([dependency_a, dependency_a, dependency_b])
      expect(spec.dependencies.size).to eq(3)
    end

    it 'can access individual dependencies' do
      spec = Specification.new('my_gem', version_1, multiple_dependencies)
      expect(spec.dependencies[0]).to eq(dependency_a)
      expect(spec.dependencies[1]).to eq(dependency_b)
      expect(spec.dependencies[2]).to eq(dependency_c)
    end

    it 'provides access to dependency properties' do
      spec = Specification.new('my_gem', version_1, [dependency_a])
      dep = spec.dependencies.first
      expect(dep.name).to eq('gem_a')
      expect(dep.requirement).to eq(requirement_gte_1)
    end
  end

  describe 'edge cases' do
    it 'works with empty string name' do
      spec = Specification.new('', version_1, empty_dependencies)
      expect(spec.name).to eq('')
      expect(spec.version).to eq(version_1)
      expect(spec.to_s).to eq(' 1.0.0')
    end

    it 'works with names containing special characters' do
      special_names = ['gem@1.0', 'gem+plus', 'gem-with-dots.rb', 'gem/with/slashes']
      special_names.each do |name|
        spec = Specification.new(name, version_1, empty_dependencies)
        expect(spec.name).to eq(name)
        expect(spec.to_s).to eq("#{name} 1.0.0")
      end
    end

    it 'works with very long names' do
      long_name = 'a' * 1000
      spec = Specification.new(long_name, version_1, empty_dependencies)
      expect(spec.name).to eq(long_name)
      expect(spec.to_s).to eq("#{long_name} 1.0.0")
    end

    it 'works with zero version' do
      zero_version = Version.new(0)
      spec = Specification.new('my_gem', zero_version, empty_dependencies)
      expect(spec.version).to eq(zero_version)
      expect(spec.to_s).to eq('my_gem 0.0.0')
    end

    it 'works with negative versions' do
      negative_version = Version.new(-1)
      spec = Specification.new('my_gem', negative_version, empty_dependencies)
      expect(spec.version).to eq(negative_version)
      expect(spec.to_s).to eq('my_gem -1.0.0')
    end

    it 'can be used as hash keys' do
      hash = {}
      spec1 = Specification.new('gem_a', version_1, single_dependency)
      spec2 = Specification.new('gem_a', version_1, multiple_dependencies)  # same name/version
      spec3 = Specification.new('gem_b', version_1, single_dependency)      # different name
      spec4 = Specification.new('gem_a', version_2, single_dependency)      # different version

      hash[spec1] = 'value1'
      hash[spec3] = 'value2'
      hash[spec4] = 'value3'

      expect(hash[spec2]).to eq('value1')  # same specification (ignoring dependencies)
      expect(hash[spec3]).to eq('value2')
      expect(hash[spec4]).to eq('value3')
      expect(hash.size).to eq(3)
    end

    it 'handles nil dependencies gracefully' do
      # Note: This might not be a valid use case in real scenarios,
      # but testing the behavior for completeness
      spec = Specification.new('my_gem', version_1, nil)
      expect(spec.name).to eq('my_gem')
      expect(spec.version).to eq(version_1)
      expect(spec.dependencies).to be_nil
    end
  end

  describe 'integration with other classes' do
    it 'correctly stores and retrieves version objects' do
      version = Version.new(5)
      spec = Specification.new('integration_gem', version, empty_dependencies)
      
      expect(spec.version).to be_a(Version)
      expect(spec.version.major).to eq(5)
      expect(spec.to_s).to eq('integration_gem 5.0.0')
    end

    it 'correctly stores and retrieves dependency objects' do
      version = Version.new(3)
      requirement = Requirement.new('~>', version)
      dependency = Dependency.new('test_dep', requirement)
      spec = Specification.new('main_gem', version_1, [dependency])
      
      stored_dep = spec.dependencies.first
      expect(stored_dep).to be_a(Dependency)
      expect(stored_dep.name).to eq('test_dep')
      expect(stored_dep.requirement).to be_a(Requirement)
      expect(stored_dep.requirement.operator).to eq('~>')
      expect(stored_dep.requirement.version.major).to eq(3)
    end

    it 'works with complex real-world-like scenarios' do
      # Simulate a Rails gem specification
      rails_version = Version.new(7)
      
      # Rails dependencies
      activerecord_req = Requirement.new('=', rails_version)
      actionpack_req = Requirement.new('>=', Version.new(6))
      nokogiri_req = Requirement.new('~>', Version.new(1))
      
      dependencies = [
        Dependency.new('activerecord', activerecord_req),
        Dependency.new('actionpack', actionpack_req),
        Dependency.new('nokogiri', nokogiri_req)
      ]
      
      rails_spec = Specification.new('rails', rails_version, dependencies)
      
      expect(rails_spec.name).to eq('rails')
      expect(rails_spec.version.major).to eq(7)
      expect(rails_spec.dependencies.size).to eq(3)
      expect(rails_spec.to_s).to eq('rails 7.0.0')
      
      # Check individual dependencies
      activerecord_dep = rails_spec.dependencies.find { |dep| dep.name == 'activerecord' }
      expect(activerecord_dep.requirement.operator).to eq('=')
      expect(activerecord_dep.requirement.version.major).to eq(7)
    end
  end

  describe 'comparison scenarios' do
    it 'distinguishes between same gem with different versions' do
      gem_v1 = Specification.new('my_gem', Version.new(1), empty_dependencies)
      gem_v2 = Specification.new('my_gem', Version.new(2), empty_dependencies)
      gem_v3 = Specification.new('my_gem', Version.new(3), empty_dependencies)

      # All should be different
      expect(gem_v1).not_to eq(gem_v2)
      expect(gem_v1).not_to eq(gem_v3)
      expect(gem_v2).not_to eq(gem_v3)

      # Hash values should be different
      expect(gem_v1.hash).not_to eq(gem_v2.hash)
      expect(gem_v1.hash).not_to eq(gem_v3.hash)
      expect(gem_v2.hash).not_to eq(gem_v3.hash)
    end

    it 'distinguishes between different gems with same version' do
      version = Version.new(1)
      gem_a = Specification.new('gem_a', version, empty_dependencies)
      gem_b = Specification.new('gem_b', version, empty_dependencies)
      gem_c = Specification.new('gem_c', version, empty_dependencies)

      # All should be different
      expect(gem_a).not_to eq(gem_b)
      expect(gem_a).not_to eq(gem_c)
      expect(gem_b).not_to eq(gem_c)

      # Hash values should be different
      expect(gem_a.hash).not_to eq(gem_b.hash)
      expect(gem_a.hash).not_to eq(gem_c.hash)
      expect(gem_b.hash).not_to eq(gem_c.hash)
    end

    it 'treats same name and version as identical regardless of dependencies' do
      spec1 = Specification.new('identical_gem', version_2, empty_dependencies)
      spec2 = Specification.new('identical_gem', version_2, single_dependency)
      spec3 = Specification.new('identical_gem', version_2, multiple_dependencies)

      expect(spec1).to eq(spec2)
      expect(spec2).to eq(spec3)
      expect(spec1).to eq(spec3)
      
      expect(spec1.hash).to eq(spec2.hash)
      expect(spec2.hash).to eq(spec3.hash)
      expect(spec1.hash).to eq(spec3.hash)
      
      expect(spec1.eql?(spec2)).to be true
      expect(spec2.eql?(spec3)).to be true
      expect(spec1.eql?(spec3)).to be true
      
      expect(spec1.to_s).to eq(spec2.to_s)
      expect(spec2.to_s).to eq(spec3.to_s)
      expect(spec1.to_s).to eq(spec3.to_s)
    end
  end
end
