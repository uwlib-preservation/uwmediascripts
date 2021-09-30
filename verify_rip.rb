require 'date'
require 'json'

logfile = 'SOME-PATH'
wavefile = ARGV[0]
data = File.readlines(logfile)
time_lines = []
time_strings = []
time_values = []
data.each {|line| time_lines << line if line.match(/(\(([0-9][0-9]|[0-9]):[0-9][0-9]\))/)}
time_lines.each do |full_line|
  full_line.split(' ').each {|value| time_strings << value.tr('()','') if value.match(/(\(([0-9][0-9]|[0-9]):[0-9][0-9]\))/)}
end

time_strings.each do |segment|
  time_values << segment.split(':')[0].to_f * 60 + segment.split(':')[1].to_f
end

ffprobe_data = JSON.parse(`mediainfo --Output=JSON #{wavefile}`)
ffprobe_time = ffprobe_data['media']['track'][0]['Duration'].to_i
log_file_time = time_values.sum

if ffprobe_time == log_file_time
  puts "yes"
else
  puts "NO!!!"
end
