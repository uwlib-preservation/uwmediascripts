targets = []
ARGV.each do |input|
  if File.file?(input) && File.extname(input).downcase == '.wav'
    targets << input
  elsif File.directory?(input)
    waves = Dir.glob("#{input}/*.wav")
    waves.each {|file| targets << file}
    flacs = Dir.glob("#{input}/*.flac")
    flacs.each {|file| targets << file}
  else
    puts "Input #{input} is not valid"
  end
end

targets.each do |audioFile|
  mp3Name = "#{File.dirname(audioFile)}/#{File.basename(audioFile,".*")}.mp3"
  puts "Generating access file for: #{audioFile}"
  `ffmpeg -i #{audioFile} -c:a libmp3lame -write_id3v1 1 -id3v2_version 3 -dither_method triangular -qscale:a 1 #{mp3Name}`
end
