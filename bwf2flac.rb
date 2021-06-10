#!/usr/bin/env ruby

require 'optparse'
require 'json'
require 'tempfile'
require 'fileutils'


ARGV.options do |opts|
  opts.on("-c", "--compress") { Mode = 'compress' }
  opts.on("-d", "--decompress") { Mode = 'decompress' }
  opts.parse!
end

targets = []
Mode = 'help' unless defined?(Mode)

def updateCue(cuePath,extension)
  oldCue = File.readlines(cuePath)
  newName = File.basename(cuePath,".*") + ".#{extension}"
  temp = Tempfile.new
  oldCue.each do|line|
    if (line.include?('FILE') && line.include?('WAVE'))
      newLine = "FILE " + '"' + newName + '"' + " WAVE\n"
      temp << newLine
    else
      temp << line
    end
  end
  temp.rewind
  FileUtils.mv(temp.path,cuePath)
end

def compress(target)
  flacPath = "#{File.dirname(target)}/#{File.basename(target,".*")}" + '.flac'
  @cuePath = "#{File.dirname(target)}/#{File.basename(target,".*")}" + '.cue'
  tagCommand = "metaflac --preserve-modtime "
  if ! @targetMetadata['media']['track'][0]['extra'].nil? && @targetMetadata['media']['track'][0]['extra']['bext_Present'] == "Yes"
    organization = @targetMetadata['media']['track'][0]['Producer']
    description = @targetMetadata['media']['track'][0]['Description']
    date = @targetMetadata['media']['track'][0]['Encoded_Date']
    sourcemedia = @targetMetadata['media']['track'][0]['Encoded_Library_Settings']
    contact = 'https://www.lib.washington.edu/'
    bextCommand = "--set-tag=ORGANIZATION='#{organization}' --set-tag=DESCRIPTION='#{description}' --set-tag=DATE='#{date}' --set-tag=SOURCEMEDIA='#{sourcemedia}' --set-tag=CONTACT='#{contact}' "
    tagCommand += bextCommand
  end

  compressCommand = "flac -f --best --keep-foreign-metadata --preserve-modtime --verify '#{target}'"
  system(compressCommand)
  if File.exist?(@cuePath)
    updateCue(@cuePath,'flac')
    cueCommand = "--set-tag-from-file=CUESHEET='#{@cuePath}' --import-cuesheet-from='#{@cuePath}' "
    tagCommand += cueCommand
  end
  tagCommand += "'#{flacPath}'"
  `#{tagCommand}`
end

def decompress(target)
  if ! @targetMetadata['media']['track'][0]['extra']['CUESHEET'].nil? && ! File.exist?(@cuePath)
    tagCommand = "metaflac --preserve-modtime --show-tag=CUESHEET '#{target}'"
    cueSheet = `#{tagCommand}`
    open(@cuePath, 'w') do |f|
      f.puts cueSheet
      f.rewind
    end
    updateCue(@cuePath,'wav')
  end
  `flac -d --keep-foreign-metadata --preserve-modtime --verify #{target}`
end

ARGV.each do |target|
  @cuePath = "#{File.dirname(target)}/#{File.basename(target,".*")}" + '.cue'
  @targetMetadata = JSON.parse(`mediainfo --Output=JSON "#{target}"`)

  if Mode == 'compress'
    compress(target)
  elsif Mode == 'decompress'
    decompress(target)
  end
end
