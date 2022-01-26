require 'json'

collection_duration = 0
target = ARGV[0].tr("\\","/")
files = Dir.glob("#{target}/**/*")
files.each do |file|
  if File.file?(file)
    puts file
    duration = JSON.parse(`mediainfo --Output=JSON "#{file}"`)['media']['track'][0]['Duration'].to_i
    collection_duration += duration
  end
end
puts "#{(collection_duration/3600.00).round(1)} hours"