require 'csv'

# input must be single iromlab batch csv file
input = ARGV[0]
metadata = CSV.open(input)
metadata.shift
target_root_path = File.dirname(input) + "/"
metadata.each do |line|
  old_iso = "#{line[0]}"
  new_iso = "#{line[3]}"
  puts old_iso
  if File.exist?("#{target_root_path}/#{line[0]}")
    puts "Renaming #{old_iso} to: #{new_iso}"
    File.rename("#{target_root_path}/#{old_iso}", "#{target_root_path}/#{new_iso}")
  end
end
