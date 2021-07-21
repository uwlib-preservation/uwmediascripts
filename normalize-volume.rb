require 'tempfile'
require 'json'

target = ARGV[0].tr("\\","/")
temp = Tempfile.new

new_name = 'NORMALIZED_' + File.basename(target)
file_path = File.dirname(target)
output_name = file_path + '/' + new_name
ffprobe_command = "ffprobe -v quiet -print_format json -show_format -show_streams -select_streams a '" + target + "'"
ffmpeg_command = "ffmpeg -i '" + target + "' -vn -af volumedetect -f null - 2> #{temp.path}"
`#{ffmpeg_command}`
ffprobe_out = JSON.parse(`#{ffprobe_command}`)
normalization_data = File.readlines(temp).select {|line| line.include? 'max_volume'}
audio_codec = ffprobe_out['streams'][0]['codec_name']
sample_rate = ffprobe_out['streams'][0]['sample_rate']
normalization_value = (-3.0 - normalization_data[0].split(' ')[4].to_f)
puts normalization_data
puts normalization_value
puts audio_codec
puts sample_rate
# `ffmpeg -i #{target} -c:v copy -c:a #{audio_codec} -ar #{sample_rate} -af volume="#{normalization_value}dB" #{output_name}`