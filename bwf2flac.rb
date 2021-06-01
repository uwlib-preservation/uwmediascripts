#!/usr/bin/env ruby

require 'optparse'
require 'json'


ARGV.options do |opts|
  opts.on("-c", "--compress") { Mode = 'compress' }
  opts.on("-d", "--decompress") { Mode = 'decompress' }
  opts.parse!
end

targets = []
Mode = 'help' unless defined?(Mode)

def compress(target)
  flacPath = "#{File.dirname(target)}/#{File.basename(target,".*")}" + '.flac'
  @cuePath = "#{File.dirname(target)}/#{File.basename(target,".*")}" + '.cue'
  tagCommand = "metaflac --preserve-modtime "
  if @targetMetadata['media']['track'][0]['extra']['bext_Present'] == "Yes"
    organization = @targetMetadata['media']['track'][0]['Producer']
    description = @targetMetadata['media']['track'][0]['Description']
    date = @targetMetadata['media']['track'][0]['Encoded_Date']
    sourcemedia = @targetMetadata['media']['track'][0]['Encoded_Library_Settings']
    contact = 'https://www.lib.washington.edu/'
    bextCommand = "--set-tag=ORGANIZATION='#{organization}' --set-tag=DESCRIPTION='#{description}' --set-tag=DATE='#{date}' --set-tag=SOURCEMEDIA='#{sourcemedia}' --set-tag=CONTACT='#{contact}' "
    tagCommand += bextCommand
  end

  compressCommand = "flac -f --best --keep-foreign-metadata --preserve-modtime --verify #{target}"
  system(compressCommand)
  if File.exist?(@cuePath)
    cueCommand = "--set-tag-from-file=CUESHEET='#{@cuePath}' --import-cuesheet-from='#{@cuePath}' "
    tagCommand += cueCommand
  end
  tagCommand += flacPath
  system(tagCommand)
end

def decompress(target)
  if ! @targetMetadata['media']['track'][0]['extra']['CUESHEET'].nil? && ! File.exist?(@cuePath)
    tagCommand = "metaflac --preserve-modtime --show-tag=CUESHEET '#{target}'"
    cueSheet = `#{tagCommand}`
    open(@cuePath, 'w') do |f|
      f.puts cueSheet
    end
  end
  `flac -d --keep-foreign-metadata --preserve-modtime --verify #{target}`
end

target = ARGV[0]
@cuePath = "#{File.dirname(target)}/#{File.basename(target,".*")}" + '.cue'
@targetMetadata = JSON.parse(`mediainfo --Output=JSON #{target}`)

if Mode == 'compress'
  compress(target)
elsif Mode=='decompress'
  decompress(target)
end
    
