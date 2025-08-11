require 'spec_helper'
require_relative '../lib/resolver_ui'
require 'stringio'

RSpec.describe ResolverUI do
  let(:output) { StringIO.new }
  let(:ui) { ResolverUI.new(output) }

  describe '#before_resolution' do
    it 'displays start message with header formatting' do
      ui.before_resolution
      
      expect(output.string).to include('🚀 依存関係解決を開始します')
      expect(output.string).to include('=' * 60)
    end

    it 'resets step counter' do
      ui.instance_variable_set(:@step_counter, 5)
      ui.before_resolution
      
      expect(ui.instance_variable_get(:@step_counter)).to eq(0)
    end
  end

  describe '#after_resolution' do
    it 'displays completion message with header formatting' do
      ui.after_resolution
      
      expect(output.string).to include('✅ 依存関係解決が完了しました')
      expect(output.string).to include('=' * 60)
    end
  end

  describe '#indicate_progress' do
    it 'displays progress dots' do
      ui.indicate_progress
      ui.indicate_progress
      ui.indicate_progress
      
      expect(output.string).to eq('...')
    end
  end

  describe '#debug_with_depth' do
    before do
      ui.instance_variable_set(:@depth, 1)
    end

    it 'displays dependency processing with step counter and indentation' do
      dependency = double('dependency', to_s: 'test-gem >= 1.0')
      
      ui.debug_with_depth(dependency)
      
      output_string = output.string
      expect(output_string).to include('[Step 1]')
      expect(output_string).to include('📦')
      expect(output_string).to include('依存関係を処理中: test-gem >= 1.0')
      expect(output_string).to include('  ') # インデント確認
    end

    it 'increments step counter on each call' do
      dependency1 = double('dependency1', to_s: 'gem1')
      dependency2 = double('dependency2', to_s: 'gem2')
      
      ui.debug_with_depth(dependency1)
      ui.debug_with_depth(dependency2)
      
      output_string = output.string
      expect(output_string).to include('[Step 1]')
      expect(output_string).to include('[Step 2]')
    end
  end

  describe '#debug_spec_selected' do
    before do
      ui.instance_variable_set(:@depth, 1)
    end

    it 'displays selected specification with proper indentation' do
      spec = double('spec', to_s: 'test-gem 1.2.3')
      
      ui.debug_spec_selected(spec)
      
      output_string = output.string
      expect(output_string).to include('✓ 仕様を選択: test-gem 1.2.3')
      expect(output_string).to include('    ') # より深いインデント
    end
  end

  describe '#debug_searching_for' do
    before do
      ui.instance_variable_set(:@depth, 1)
    end

    it 'displays search message with proper indentation' do
      dependency = double('dependency', to_s: 'search-gem >= 2.0')
      
      ui.debug_searching_for(dependency)
      
      output_string = output.string
      expect(output_string).to include('🔍 仕様を検索中: search-gem >= 2.0')
      expect(output_string).to include('    ')
    end
  end

  describe '#debug_found_specs' do
    before do
      ui.instance_variable_set(:@depth, 1)
    end

    context 'when no specs are found' do
      it 'displays warning message' do
        ui.debug_found_specs([])
        
        expect(output.string).to include('⚠️  利用可能な仕様が見つかりません')
      end
    end

    context 'when specs are found' do
      it 'displays count and list of specifications' do
        spec1 = double('spec1', to_s: 'gem1 1.0.0')
        spec2 = double('spec2', to_s: 'gem1 2.0.0')
        specs = [spec1, spec2]
        
        ui.debug_found_specs(specs)
        
        output_string = output.string
        expect(output_string).to include('📋 2個の仕様が見つかりました:')
        expect(output_string).to include('1. gem1 1.0.0')
        expect(output_string).to include('2. gem1 2.0.0')
      end
    end
  end

  describe '#debug_conflict' do
    before do
      ui.instance_variable_set(:@depth, 2)
    end

    it 'displays conflict message with proper indentation' do
      conflict = double('conflict', to_s: 'version conflict on gem-x')
      
      ui.debug_conflict(conflict)
      
      output_string = output.string
      expect(output_string).to include('⚡ 競合が発生しました: version conflict on gem-x')
      expect(output_string).to include('    ') # depth 2のインデント
    end
  end

  describe '#debug_backtracking' do
    before do
      ui.instance_variable_set(:@depth, 2)
    end

    it 'displays backtracking message with proper indentation' do
      spec = double('spec', to_s: 'backtrack-gem 1.0.0')
      
      ui.debug_backtracking(spec)
      
      output_string = output.string
      expect(output_string).to include('🔙 バックトラッキング中: backtrack-gem 1.0.0')
    end
  end

  describe '#debug_adding_spec' do
    before do
      ui.instance_variable_set(:@depth, 1)
    end

    it 'displays adding spec message' do
      spec = double('spec', to_s: 'new-gem 1.5.0')
      
      ui.debug_adding_spec(spec)
      
      output_string = output.string
      expect(output_string).to include('➕ 仕様を追加: new-gem 1.5.0')
    end
  end

  describe '#debug_removing_spec' do
    before do
      ui.instance_variable_set(:@depth, 1)
    end

    it 'displays removing spec message' do
      spec = double('spec', to_s: 'old-gem 0.9.0')
      
      ui.debug_removing_spec(spec)
      
      output_string = output.string
      expect(output_string).to include('➖ 仕様を削除: old-gem 0.9.0')
    end
  end

  describe '#debug_processing_complete' do
    before do
      ui.instance_variable_set(:@depth, 1)
    end

    it 'displays processing complete message' do
      ui.debug_processing_complete
      
      expect(output.string).to include('✨ 依存関係の処理が完了しました')
    end
  end

  describe 'depth management' do
    it 'adjusts indentation based on depth' do
      ui.instance_variable_set(:@depth, 0)
      dependency0 = double('dep0', to_s: 'depth-0')
      ui.debug_with_depth(dependency0)
      
      ui.instance_variable_set(:@depth, 2)
      dependency2 = double('dep2', to_s: 'depth-2')
      ui.debug_with_depth(dependency2)
      
      output_lines = output.string.split("\n")
      depth_0_line = output_lines.find { |line| line.include?('depth-0') }
      depth_2_line = output_lines.find { |line| line.include?('depth-2') }
      
      # depth 0はインデントなし、depth 2は4スペースのインデント
      expect(depth_0_line).not_to start_with('  ')
      expect(depth_2_line).to include('    📦') # 4スペース + 絵文字
    end
  end

  describe 'timestamp formatting' do
    it 'includes timestamp in step logs' do
      dependency = double('dependency', to_s: 'time-test')
      
      ui.debug_with_depth(dependency)
      
      # タイムスタンプの形式をテスト（HH:MM:SS.sss）
      expect(output.string).to match(/\[\d{2}:\d{2}:\d{2}\.\d{3}\]/)
      expect(output.string).to include('📦 [Step 1] 依存関係を処理中: time-test')
    end
  end
end
