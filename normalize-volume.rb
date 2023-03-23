require 'tempfile'
require 'json'

targets = Dir.glob("#{ARGV[0]}/**/*.wav")
@mezzanines = []
@access_files = []

def normalize_mezz(target)
  puts "Processing: #{target}"
  temp = Tempfile.new
  file_path = File.dirname(target)
  file_base = File.basename(target, ".*")
  output_name = file_path + '/' + file_base + '_48kHz.wav'
  ffprobe_command = "ffprobe -v quiet -print_format json -show_format -show_streams -select_streams a '" + target + "'"
  ffmpeg_command = "ffmpeg -i '" + target + "' -vn -af volumedetect -f null - 2> #{temp.path}"
  `#{ffmpeg_command}`
  ffprobe_out = JSON.parse(`#{ffprobe_command}`)
  normalization_data = File.readlines(temp).select {|line| line.include? 'max_volume'}
  codingHistory = nil
  normalization_value = (-3.0 - normalization_data[0].split(' ')[4].to_f)
  puts normalization_data
  puts normalization_value
  # get values for BEXT
  if codingHistory.nil?
    if `ffmpeg -i "#{target}" -c:v copy -c:a pcm_s16le -ar 48000 -dither_method triangular -map_metadata -1  -af volume="#{normalization_value}dB" "#{output_name}"`
      @mezzanines << output_name
    end
  else
    mValue = codingHistory.split(',').select {|value| value.include?("M=")}.last
    updatedCodingHistory = codingHistory + "\nA=PCM,F=48000,W=16,#{mValue},T=FFmpeg; mezzanine"
    originator = ffprobe_out["format"]['tags']['encoded_by']
    description = ffprobe_out["format"]['tags']["comment"].split("Original")[0]
    date = Time.now.to_s.split(' ')[0]
    time = Time.now.to_s.split(' ')[1]
    if `ffmpeg -i "#{target}" -c:v copy -c:a pcm_s16le -ar 48000 -dither_method triangular -map_metadata -1 -write_bext 1 -metadata "origination_date=#{date}" -metadata "origination_time=#{time}" -metadata "description=#{description}" -metadata "originator=#{originator}" -metadata "coding_history=#{updatedCodingHistory}" -metadata "IARL=#{originator}" -af volume="#{normalization_value}dB" "#{output_name}"`
      @mezzanines << output_name
    end
  end
  output_name
end


def make_access(target)
  file_path = File.dirname(target)
  file_base = File.basename(target, ".*")
  output_name = file_path + '/' + file_base + '.mp3'
  if `ffmpeg -i "#{target}" -write_id3v1 1 -id3v2_version 3 -out_sample_rate 48k -qscale:a 1 "#{output_name}"`
    @access_files << output_name
  end
end

def clean_up_files(targets, mezzanines, access_files)
  access = "#{ARGV[0]}/access"
  mezzanine = "#{ARGV[0]}/mezzanine"
  preservationFiles = "#{ARGV[0]}/preservationFiles"
  Dir.mkdir(access)
  Dir.mkdir(mezzanine)
  Dir.mkdir(preservationFiles)
  targets.each {|file| FileUtils.mv(file, preservationFiles)}
  mezzanines.each {|file| FileUtils.mv(file, mezzanineFiles)}
  access_files.each {|file| FileUtils.mv(file, accessFiles)}
end



targets.each do |target|
  new_target = normalize_mezz(target)
  make_access(new_target) unless new_target.nil?
end

clean_up_files(targets, @mezzanines, @access_files)