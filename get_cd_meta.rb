require 'json'
prior_drive_info = ''
cd_iterator = 1
Output_dir = ARGV[0]
Drive = ARGV[1]

if (Output_dir.nil? || ! File.exist?(Output_dir))
  puts "Please use valid output directory!"
  exit
end

loop do
  drive_info = `mediainfo --Output=JSON #{Drive}:/`
  if drive_info == "\n"
    puts "Waiting for disc"
  elsif prior_drive_info == drive_info
    puts "Same Disc Still Present!"
  else
    parsed_data = JSON.parse(drive_info)
    track_lengths = []
    parsed_data.each do |track|
      track_lengths << track['media']['track'][0]['Duration'].to_f
    end
    time_info = {"total_length" => track_lengths.sum}
    log_file = "#{Output_dir}/CD_#{cd_iterator.to_s}.log"
    puts "Writing: #{log_file}"
    File.open(log_file,"w") do |f|
      f.write(time_info.to_json)
      f.close
    end
    cd_iterator += 1
    prior_drive_info = drive_info
  end
  sleep 45
end
