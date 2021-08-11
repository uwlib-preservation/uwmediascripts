targets = []
scriptDir = __dir__
ARGV.each do |input|
  input = input.tr("\\","/")
  if File.file?(input) && File.extname(input).downcase == '.wav'
    targets << input
  elsif File.directory?(input)
    waves = Dir.glob("#{input}/*.wav")
    waves.each {|file| targets << file}
  else
    puts "Input #{input} is not valid"
  end
end

targets.each do |waveFile|
  parsedName = waveFile.split("_")
  itemNumber =  File.basename(parsedName[2], ".*")
  puts "Embedding metadata in #{waveFile}"
  puts "Identified Item Number: #{itemNumber}"
  system("ruby", "#{scriptDir}/uwmetaedit2", '-i', itemNumber, waveFile )
end