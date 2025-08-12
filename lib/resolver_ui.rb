require 'molinillo'

class ResolverUI
  include Molinillo::UI

  def initialize(debug = false)
    @debug = debug
  end

  def output
    STDOUT
  end

  def debug?
    @debug
  end

  def before_resolution
    puts "🚀 Resolving dependencies..."
  end

  def after_resolution
    puts "✅ Resolution complete!"
  end

  def progress_rate
    0.33
  end

  def indicate_progress
    print "."
  end

  def debug(depth = 0)
    if debug?
      debug_info = yield
      debug_info = debug_info.inspect unless debug_info.is_a?(String)
      debug_info = debug_info.split("\n").map { |s| ":#{depth.to_s.rjust 4}: #{s}" }
      puts debug_info
    end
  end

  private

  def puts(*args)
    output.puts(*args) if debug?
  end

  def print(*args)
    output.print(*args) if debug?
  end
end
