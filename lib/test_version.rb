require_relative 'main'

# バージョン制約のテスト
req = Requirement.new('rack', '= 2.0.0')
pkg_correct = Package.new('rack', '2.0.0')
pkg_wrong = Package.new('rack', '2.1.0')

puts "Requirement: #{req}"
puts "Package (correct): #{pkg_correct}"
puts "Satisfied? #{req.satisfied_by?(pkg_correct)}"
puts "Package (wrong): #{pkg_wrong}"
puts "Satisfied? #{req.satisfied_by?(pkg_wrong)}"

puts "\n--- Testing '>=' constraint ---"
req2 = Requirement.new('rack', '>= 2.1.0')
puts "Requirement: #{req2}"
puts "Package 2.0.0: satisfied? #{req2.satisfied_by?(Package.new('rack', '2.0.0'))}"
puts "Package 2.1.0: satisfied? #{req2.satisfied_by?(Package.new('rack', '2.1.0'))}"
puts "Package 3.0.0: satisfied? #{req2.satisfied_by?(Package.new('rack', '3.0.0'))}"
