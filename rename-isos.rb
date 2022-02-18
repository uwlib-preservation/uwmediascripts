require 'csv'

input = ARGV[0]
metadata = CSV.open(input)
metadata.shift
target_root_path = File.dirname(input) + "/"
metadata.each do |line|
  old_iso = "#{line[4]}.iso"
  new_iso = "#{line[3]}.iso"
  puts old_iso
  if File.exist?("#{target_root_path}/#{line[0]}/#{old_iso}")
    puts "Renaming #{old_iso} to: #{new_iso}"
    File.rename("#{target_root_path}/#{line[0]}/#{old_iso}", "#{target_root_path}/#{line[0]}/#{new_iso}")
  end
end