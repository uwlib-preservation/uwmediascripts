# Script to make DVDs from input
# Formatting of tsv is: File name \t DVD title \t Film or NTSC
# Depends on installations of mediainfo, ffmpeg, dvdauthor and genisoimage

require 'csv'
require 'fileutils'
require 'json'
@missing_files =[]

Target_dir = ARGV[0]
input_tsv = Dir.glob("#{Target_dir}/*.tsv")[0]
targets = CSV.read(input_tsv, col_sep: "\t")

def get_ffmpeg_command(scan_type,frame_rate,file_path)
  if frame_rate.to_f <= 24
    output_format = 'film-dvd'
  elsif frame_rate.to_f <= 30  && frame_rate.to_f > 25
    output_format = 'ntsc-dvd'
  end
  if scan_type != 'Progressive' && output_format == 'film-dvd'
    video_filter = ' -vf fieldmatch,yadif,decimate '
  elsif scan_type != 'Progressive'
    video_filter = ' -vf yadif '
  else
    video_filter = ' '
  end
  ffmpeg_command = "ffmpeg -i #{file_path} #{video_filter} -target #{output_format} -y TARGET-for-dvd.mpg"
end

targets.each do |target|
  file_name = target[0]
  file_path = Dir.glob("#{Target_dir}/**/#{file_name}")[0]
  if file_path.empty?
    puts "Missing file: #{file_name}"
    @missing_files << target[0]
    next
  end
  title = target[1]
  target_format = target[2]
  target_info = JSON.parse(`mediainfo --Output=JSON #{file_path}`)
  frame_rate = target_info['media']['track'][1]['FrameRate']
  scan_type = target_info['media']['track'][1]['ScanType']
  ffmpeg_command = get_ffmpeg_command(scan_type,frame_rate,file_path)
  Dir.chdir(File.dirname(file_path))
  system(ffmpeg_command)
  `export VIDEO_FORMAT=NTSC && dvdauthor -t TARGET-for-dvd.mpg --video=NTSC -o DVD`
  `export VIDEO_FORMAT=NTSC && dvdauthor -T -o DVD`
  `export VIDEO_FORMAT=NTSC && genisoimage -dvd-video -V "#{title}" -o #{File.basename(file_path,".*")}.iso ./DVD`
  FileUtils.remove_dir('DVD')
  File.delete('TARGET-for-dvd.mpg')
end

