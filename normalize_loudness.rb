require 'json'

input = ARGV[0]
file_extension = File.extname(input)
output_name = input.gsub(file_extension, "") + '_normalized' + file_extension
puts "Gathering Loudness Information: #{File.basename(input)}"
ffmpeg_out = `ffmpeg -nostdin -i "#{input}" -af loudnorm=print_format=json -f null - 2>&1`.split("\n")
ffprobe_out = JSON.parse`ffprobe -v quiet -show_streams -select_streams a -print_format json "#{input}"`
audio_codec = ffprobe_out['streams'][0]['codec_name']
sample_rate = ffprobe_out['streams'][0]['sample_rate']

audio_json = JSON.parse(ffmpeg_out.last(12).join)
puts "Normalizing: #{File.basename(input)}"
puts`ffmpeg -nostdin -i #{input} -c:v copy -c:a #{audio_codec} -ar #{sample_rate} -af afftdn,loudnorm=dual_mono=true:measured_I=#{audio_json['input_i']}:measured_TP=#{audio_json['input_tp']}:measured_LRA=#{audio_json['input_lra']}:measured_thresh=#{audio_json['input_thresh']}:offset=#{audio_json['target_offset']}:linear=true -ar 48k -y #{output_name}`