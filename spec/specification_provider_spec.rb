require 'spec_helper'
require_relative '../lib/specification_provider'

RSpec.describe SpecificationProvider do
  # テスト用のサンプル仕様を作成
  let(:test_specifications) do
    # Rails エコシステムのサンプル
    rails_v6 = Specification.new('rails', Version.new(6), [
      Dependency.new('activerecord', Requirement.new('=', Version.new(6))),
      Dependency.new('actionpack', Requirement.new('=', Version.new(6)))
    ])
    
    rails_v7 = Specification.new('rails', Version.new(7), [
      Dependency.new('activerecord', Requirement.new('=', Version.new(7))),
      Dependency.new('actionpack', Requirement.new('=', Version.new(7))),
      Dependency.new('nokogiri', Requirement.new('>=', Version.new(1)))
    ])

    # ActiveRecord
    activerecord_v6 = Specification.new('activerecord', Version.new(6), [
      Dependency.new('activesupport', Requirement.new('=', Version.new(6)))
    ])
    
    activerecord_v7 = Specification.new('activerecord', Version.new(7), [
      Dependency.new('activesupport', Requirement.new('=', Version.new(7)))
    ])

    # ActionPack
    actionpack_v6 = Specification.new('actionpack', Version.new(6), [
      Dependency.new('activesupport', Requirement.new('=', Version.new(6)))
    ])
    
    actionpack_v7 = Specification.new('actionpack', Version.new(7), [
      Dependency.new('activesupport', Requirement.new('=', Version.new(7)))
    ])

    # ActiveSupport
    activesupport_v6 = Specification.new('activesupport', Version.new(6), [])
    activesupport_v7 = Specification.new('activesupport', Version.new(7), [])

    # Nokogiri
    nokogiri_v1 = Specification.new('nokogiri', Version.new(1), [])
    nokogiri_v2 = Specification.new('nokogiri', Version.new(2), [])

    # RSpec
    rspec_v3 = Specification.new('rspec', Version.new(3), [
      Dependency.new('rspec-core', Requirement.new('=', Version.new(3)))
    ])
    
    rspec_v4 = Specification.new('rspec', Version.new(4), [
      Dependency.new('rspec-core', Requirement.new('=', Version.new(4)))
    ])

    # RSpec Core
    rspec_core_v3 = Specification.new('rspec-core', Version.new(3), [])
    rspec_core_v4 = Specification.new('rspec-core', Version.new(4), [])

    # 単純なライブラリ
    json_v1 = Specification.new('json', Version.new(1), [])
    json_v2 = Specification.new('json', Version.new(2), [])

    [
      rails_v6, rails_v7,
      activerecord_v6, activerecord_v7,
      actionpack_v6, actionpack_v7,
      activesupport_v6, activesupport_v7,
      nokogiri_v1, nokogiri_v2,
      rspec_v3, rspec_v4,
      rspec_core_v3, rspec_core_v4,
      json_v1, json_v2
    ]
  end

  let(:provider) { SpecificationProvider.new(test_specifications) }
  let(:version_1) { Version.new(1) }
  let(:version_2) { Version.new(2) }
  let(:version_3) { Version.new(3) }

  describe '#initialize' do
    it 'creates a provider with provided specifications' do
      # インターフェースメソッドを通じて仕様が正しく登録されているかテスト
      rails_dep = Dependency.new('rails', Requirement.new('>=', version_1))
      results = provider.search_for(rails_dep)
      expect(results).not_to be_empty
    end

    it 'creates a provider with empty specifications when none provided' do
      empty_provider = SpecificationProvider.new
      rails_dep = Dependency.new('rails', Requirement.new('>=', version_1))
      results = empty_provider.search_for(rails_dep)
      expect(results).to be_empty
    end

    it 'creates a provider with custom specifications' do
      custom_specs = [
        Specification.new('custom', Version.new(1), [])
      ]
      custom_provider = SpecificationProvider.new(custom_specs)
      custom_dep = Dependency.new('custom', Requirement.new('=', Version.new(1)))
      results = custom_provider.search_for(custom_dep)
      expect(results.size).to eq(1)
      expect(results.first.name).to eq('custom')
    end
  end

  describe '#name_for' do
    it 'returns the name of the dependency' do
      dependency = Dependency.new('rails', Requirement.new('>=', version_1))
      expect(provider.name_for(dependency)).to eq('rails')
    end

    it 'works with different dependency names' do
      dep1 = Dependency.new('activerecord', Requirement.new('=', version_2))
      dep2 = Dependency.new('nokogiri', Requirement.new('<', version_3))
      
      expect(provider.name_for(dep1)).to eq('activerecord')
      expect(provider.name_for(dep2)).to eq('nokogiri')
    end
  end

  describe '#search_for' do
    it 'returns specifications that match the requirement' do
      dependency = Dependency.new('rails', Requirement.new('>=', Version.new(6)))
      results = provider.search_for(dependency)
      
      expect(results).to be_an(Array)
      expect(results.size).to eq(2)  # rails v6 and v7
      expect(results.map(&:version).map(&:major)).to eq([7, 6])  # sorted descending
    end

    it 'returns empty array for non-existent packages' do
      dependency = Dependency.new('non-existent', Requirement.new('>=', version_1))
      results = provider.search_for(dependency)
      
      expect(results).to be_empty
    end

    it 'filters by version requirements correctly' do
      # Only rails v7 should match '>= 7'
      dependency = Dependency.new('rails', Requirement.new('>=', Version.new(7)))
      results = provider.search_for(dependency)
      
      expect(results.size).to eq(1)
      expect(results.first.version.major).to eq(7)
    end

    it 'handles exact version requirements' do
      dependency = Dependency.new('rails', Requirement.new('=', Version.new(6)))
      results = provider.search_for(dependency)
      
      expect(results.size).to eq(1)
      expect(results.first.version.major).to eq(6)
    end

    it 'sorts results by version descending' do
      dependency = Dependency.new('json', Requirement.new('>=', version_1))
      results = provider.search_for(dependency)
      
      expect(results.size).to eq(2)
      expect(results.map(&:version).map(&:major)).to eq([2, 1])
    end
  end

  describe '#dependencies_for' do
    it 'returns dependencies of a specification' do
      rails_spec = provider.search_for(Dependency.new('rails', Requirement.new('=', Version.new(7)))).first
      dependencies = provider.dependencies_for(rails_spec)
      
      expect(dependencies).to be_an(Array)
      expect(dependencies.size).to eq(3)  # activerecord, actionpack, nokogiri
      expect(dependencies.map(&:name)).to include('activerecord', 'actionpack', 'nokogiri')
    end

    it 'returns empty array for specifications with no dependencies' do
      json_spec = provider.search_for(Dependency.new('json', Requirement.new('=', version_1))).first
      dependencies = provider.dependencies_for(json_spec)
      
      expect(dependencies).to be_empty
    end

    it 'handles nil dependencies gracefully' do
      spec = Specification.new('test', version_1, nil)
      dependencies = provider.dependencies_for(spec)
      
      expect(dependencies).to be_nil
    end
  end

  describe '#requirement_satisfied_by?' do
    let(:rails_v7_spec) { Specification.new('rails', Version.new(7), []) }
    let(:rails_v6_spec) { Specification.new('rails', Version.new(6), []) }

    it 'returns true when requirement is satisfied' do
      requirement = Dependency.new('rails', Requirement.new('>=', Version.new(6)))
      
      expect(provider.requirement_satisfied_by?(requirement, nil, rails_v7_spec)).to be true
      expect(provider.requirement_satisfied_by?(requirement, nil, rails_v6_spec)).to be true
    end

    it 'returns false when requirement is not satisfied' do
      requirement = Dependency.new('rails', Requirement.new('>', Version.new(7)))
      
      expect(provider.requirement_satisfied_by?(requirement, nil, rails_v7_spec)).to be false
      expect(provider.requirement_satisfied_by?(requirement, nil, rails_v6_spec)).to be false
    end

    it 'returns false when names do not match' do
      requirement = Dependency.new('activerecord', Requirement.new('>=', Version.new(6)))

      expect(provider.requirement_satisfied_by?(requirement, nil, rails_v7_spec)).to be false
    end

    it 'returns false when spec has different name' do
      requirement = Dependency.new('rails', Requirement.new('>=', Version.new(6)))
      different_spec = Specification.new('activerecord', Version.new(7), [])

      expect(provider.requirement_satisfied_by?(requirement, nil, different_spec)).to be false
    end
  end

  describe '#dependencies_equal?' do
    let(:dep1) { Dependency.new('rails', Requirement.new('>=', version_1)) }
    let(:dep2) { Dependency.new('rspec', Requirement.new('=', version_2)) }
    let(:dep3) { Dependency.new('json', Requirement.new('<', version_3)) }

    it 'returns true for identical dependency arrays' do
      deps1 = [dep1, dep2]
      deps2 = [dep1, dep2]
      
      expect(provider.dependencies_equal?(deps1, deps2)).to be true
    end

    it 'returns true for same dependencies in different order' do
      deps1 = [dep1, dep2]
      deps2 = [dep2, dep1]
      
      expect(provider.dependencies_equal?(deps1, deps2)).to be true
    end

    it 'returns false for different dependencies' do
      deps1 = [dep1, dep2]
      deps2 = [dep1, dep3]
      
      expect(provider.dependencies_equal?(deps1, deps2)).to be false
    end

    it 'returns false for different sized arrays' do
      deps1 = [dep1]
      deps2 = [dep1, dep2]
      
      expect(provider.dependencies_equal?(deps1, deps2)).to be false
    end

    it 'returns true for both nil' do
      expect(provider.dependencies_equal?(nil, nil)).to be true
    end

    it 'returns false when one is nil' do
      deps = [dep1]
      
      expect(provider.dependencies_equal?(deps, nil)).to be false
      expect(provider.dependencies_equal?(nil, deps)).to be false
    end

    it 'returns true for both empty arrays' do
      expect(provider.dependencies_equal?([], [])).to be true
    end
  end

  describe '#sort_dependencies' do
    let(:dep_rails) { Dependency.new('rails', Requirement.new('=', version_1)) }
    let(:dep_rspec) { Dependency.new('rspec', Requirement.new('>=', version_1)) }
    let(:dep_json) { Dependency.new('json', Requirement.new('<', version_1)) }
    let(:dependencies) { [dep_rspec, dep_rails, dep_json] }

    it 'sorts dependencies by name when no conflicts' do
      sorted = provider.sort_dependencies(dependencies, nil, {})
      
      expect(sorted.map(&:name)).to eq(['rails', 'json', 'rspec'])
    end

    it 'prioritizes conflicted dependencies' do
      conflicts = { 'rspec' => 'some conflict' }
      sorted = provider.sort_dependencies(dependencies, nil, conflicts)
      
      # rspec should come first due to conflict
      expect(sorted.first.name).to eq('rspec')
    end

    it 'considers requirement restrictiveness' do
      # = is more restrictive than < which is more restrictive than >=
      deps = [
        Dependency.new('pkg', Requirement.new('>=', version_1)),  # less restrictive
        Dependency.new('pkg', Requirement.new('=', version_1)),   # most restrictive
        Dependency.new('pkg', Requirement.new('<', version_1))    # middle restrictive
      ]
      
      sorted = provider.sort_dependencies(deps, nil, {})
      operators = sorted.map { |d| d.requirement.operator }
      
      expect(operators).to eq(['=', '<', '>='])
    end
  end

  describe '#name_for_locking_dependency_source' do
    it 'returns the dependency name' do
      dependency = Dependency.new('rails', Requirement.new('>=', version_1))
      expect(provider.name_for_locking_dependency_source(dependency)).to eq('rails')
    end
  end

  describe '#name_for_explicit_dependency_source' do
    it 'returns the dependency name' do
      dependency = Dependency.new('rails', Requirement.new('>=', version_1))
      expect(provider.name_for_explicit_dependency_source(dependency)).to eq('rails')
    end
  end

  describe '#allow_missing?' do
    it 'returns false by default' do
      dependency = Dependency.new('non-existent', Requirement.new('>=', version_1))
      expect(provider.allow_missing?(dependency)).to be false
    end
  end

  describe 'registration methods' do
    let(:new_provider) { SpecificationProvider.new }
    let(:custom_spec) { Specification.new('custom', version_1, []) }

    describe 'private registration methods' do
      it 'registers specifications during initialization' do
        specs = [
          Specification.new('pkg1', version_1, []),
          Specification.new('pkg2', version_2, [])
        ]
        
        provider_with_specs = SpecificationProvider.new(specs)
        
        # 登録されたパッケージがsearch_forで見つかることを確認
        pkg1_dep = Dependency.new('pkg1', Requirement.new('=', version_1))
        pkg2_dep = Dependency.new('pkg2', Requirement.new('=', version_2))
        
        expect(provider_with_specs.search_for(pkg1_dep)).not_to be_empty
        expect(provider_with_specs.search_for(pkg2_dep)).not_to be_empty
      end

      it 'sorts specifications by version descending during initialization' do
        spec_v1 = Specification.new('test', version_1, [])
        spec_v3 = Specification.new('test', version_3, [])
        spec_v2 = Specification.new('test', version_2, [])
        
        provider_with_specs = SpecificationProvider.new([spec_v1, spec_v3, spec_v2])
        
        # すべてのバージョンを検索してソート順を確認
        test_dep = Dependency.new('test', Requirement.new('>=', version_1))
        specs = provider_with_specs.search_for(test_dep)
        versions = specs.map(&:version).map(&:major)
        expect(versions).to eq([3, 2, 1])
      end
    end
  end

  describe 'integration scenarios' do
    it 'can resolve a simple dependency chain' do
      # Test that we can find rails v7 and its dependencies
      rails_dep = Dependency.new('rails', Requirement.new('=', Version.new(7)))
      rails_specs = provider.search_for(rails_dep)
      
      expect(rails_specs.size).to eq(1)
      rails_spec = rails_specs.first
      
      # Check rails dependencies
      rails_deps = provider.dependencies_for(rails_spec)
      expect(rails_deps.map(&:name)).to include('activerecord', 'actionpack', 'nokogiri')
      
      # Check that we can find activerecord v7
      activerecord_dep = rails_deps.find { |dep| dep.name == 'activerecord' }
      activerecord_specs = provider.search_for(activerecord_dep)
      
      expect(activerecord_specs.size).to eq(1)
      expect(activerecord_specs.first.version.major).to eq(7)
    end

    it 'handles version conflicts correctly' do
      # Request rails v6 - should not include nokogiri dependency
      rails_dep = Dependency.new('rails', Requirement.new('=', Version.new(6)))
      rails_specs = provider.search_for(rails_dep)
      
      rails_spec = rails_specs.first
      rails_deps = provider.dependencies_for(rails_spec)
      
      expect(rails_deps.map(&:name)).to include('activerecord', 'actionpack')
      expect(rails_deps.map(&:name)).not_to include('nokogiri')
    end
  end
end
