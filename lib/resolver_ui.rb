require 'molinillo'

class ResolverUI
  include Molinillo::UI

  def initialize(output = $stdout)
    @output = output
    @depth = 0
    @step_counter = 0
  end

  # 解決開始時に呼ばれる
  def before_resolution
    @step_counter = 0
    log_header("🚀 依存関係解決を開始します")
  end

  # 解決完了時に呼ばれる
  def after_resolution
    log_header("✅ 依存関係解決が完了しました")
  end

  # 依存関係の追加時に呼ばれる
  # @param requirement [Object] 追加される依存関係
  def indicate_progress
    # プログレス表示（ドットを表示）
    @output.print "."
    @output.flush
  end

  # バックトラッキング開始時に呼ばれる
  def debug(depth = 0)
    @depth = depth
    yield if block_given?
  end

  # 新しい依存関係を処理開始時に呼ばれる
  # @param dependency [Object] 処理する依存関係
  def debug_with_depth(dependency)
    @step_counter += 1
    indent = "  " * @depth
    log_step("#{indent}📦 [Step #{@step_counter}] 依存関係を処理中: #{dependency}")
  end

  # 仕様の選択時に呼ばれる
  # @param spec [Object] 選択された仕様
  def debug_spec_selected(spec)
    indent = "  " * (@depth + 1)
    log_info("#{indent}✓ 仕様を選択: #{spec}")
  end

  # 仕様の検索開始時に呼ばれる
  # @param dependency [Object] 検索対象の依存関係
  def debug_searching_for(dependency)
    indent = "  " * (@depth + 1)
    log_info("#{indent}🔍 仕様を検索中: #{dependency}")
  end

  # 利用可能な仕様が見つかった時に呼ばれる
  # @param specs [Array] 見つかった仕様の配列
  def debug_found_specs(specs)
    indent = "  " * (@depth + 1)
    if specs.empty?
      log_warning("#{indent}⚠️  利用可能な仕様が見つかりません")
    else
      log_success("#{indent}📋 #{specs.size}個の仕様が見つかりました:")
      specs.each_with_index do |spec, index|
        log_info("#{indent}   #{index + 1}. #{spec}")
      end
    end
  end

  # 競合発生時に呼ばれる
  # @param conflict [Object] 発生した競合
  def debug_conflict(conflict)
    indent = "  " * @depth
    log_error("#{indent}⚡ 競合が発生しました: #{conflict}")
  end

  # バックトラッキング時に呼ばれる
  # @param spec [Object] バックトラッキング対象の仕様
  def debug_backtracking(spec)
    indent = "  " * @depth
    log_warning("#{indent}🔙 バックトラッキング中: #{spec}")
  end

  # 依存関係の追加時に呼ばれる
  # @param spec [Object] 追加される仕様
  def debug_adding_spec(spec)
    indent = "  " * (@depth + 1)
    log_success("#{indent}➕ 仕様を追加: #{spec}")
  end

  # 依存関係の削除時に呼ばれる
  # @param spec [Object] 削除される仕様
  def debug_removing_spec(spec)
    indent = "  " * (@depth + 1)
    log_warning("#{indent}➖ 仕様を削除: #{spec}")
  end

  # 依存関係の処理完了時に呼ばれる
  def debug_processing_complete
    indent = "  " * @depth
    log_info("#{indent}✨ 依存関係の処理が完了しました")
  end

  private

  # ヘッダー用のログ出力
  def log_header(message)
    @output.puts "\n" + "=" * 60
    @output.puts message
    @output.puts "=" * 60
  end

  # ステップ用のログ出力（重要な処理）
  def log_step(message)
    timestamp = Time.now.strftime("%H:%M:%S.%3N")
    @output.puts "\n[#{timestamp}] #{message}"
  end

  # 情報用のログ出力
  def log_info(message)
    @output.puts message
  end

  # 成功用のログ出力（緑色っぽい表現）
  def log_success(message)
    @output.puts message
  end

  # 警告用のログ出力（黄色っぽい表現）
  def log_warning(message)
    @output.puts message
  end

  # エラー用のログ出力（赤色っぽい表現）
  def log_error(message)
    @output.puts message
  end
end
