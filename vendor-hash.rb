failed = []
no_md5 = []

TargetDir = ARGV[0]
Extension = ARGV[1]

files = Dir.glob("#{TargetDir}/**/*.#{Extension}")

files.each do |target|
  if File.exist?(target + ".md5")
    puts "Calculating hash for #{target}"
    file_md5 = `md5sum "#{target}"`.split(" ")[0]
    stored_md5 = File.readlines(target + ".md5")[0].split(" ")[0]
    if file_md5.downcase == stored_md5.downcase
      puts "#{target}: PASS"
    else
      puts "#{target}: MD5 FAIL!"
      failed << target
    end
  else
    puts "No MD5 file found"
    no_md5 << target
  end
end

if failed.count > 0
  puts "These files failed MD5 verification!"
  failed.each {|file| puts file}
else
  puts "All tested files passed MD5 verification"
end
if no_md5.count > 0
  puts "No MD5 found for these files:"
  no_md5.each {|file| puts file}
end