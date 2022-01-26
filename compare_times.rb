require 'json'

class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end
  def red
    colorize(31)
  end
end

target_dir = ARGV[0].tr("\\","/")
@waves = Dir.glob("#{target_dir}/*.wav")
@logs = Dir.glob("#{target_dir}/*.log")
wavesSorted = @waves.sort_by {|filename| File.mtime(filename) }
logsSorted = @logs.sort_by {|filename| File.mtime(filename) }

wavesSorted.each_with_index do |wave, index|
  log_time = JSON.parse(File.read(logsSorted[index]))['total_length'].to_f.round(2)
  wave_time = JSON.parse(`mediainfo --Output=JSON "#{wave}"`)['media']['track'][0]['Duration'].to_f.round(2)
  puts wave
  puts "File: #{wave_time}"
  puts "Log: #{log_time}"
  if log_time == wave_time
    puts "PASS!"
  else
    puts "FAIL!!".red
  end
end
