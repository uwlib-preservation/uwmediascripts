require 'json'

target_dir = ARGV[0].tr("\\","/")
@waves = Dir.glob("#{target_dir}/*.wav")
@logs = Dir.glob("#{target_dir}/*.log")
wavesSorted = @waves.sort_by {|filename| File.mtime(filename) }
logsSorted = @logs = Dir.glob("#{target_dir}/*.log")

wavesSorted.each_with_index do |wave, index|
  log_time = JSON.parse(File.read(logsSorted[index]))['total_length'].to_f.round(2)
  wave_time = JSON.parse(`mediainfo --Output=JSON "#{wave}"`)['media']['track'][0]['Duration'].to_f.round(2)
  puts wave
  puts wave_time
  puts log_time
  if log_time == wave_time
    puts "PASS!"
  else
    puts "FAIL!!"
  end
end
