require 'json'
target = ARGV[0]
flacPath = "#{File.dirname(target)}/#{File.basename(target,".*")}" + '.flac'
bwfMetadata = JSON.parse(`mediainfo --Output=JSON #{target}`)
organization = bwfMetadata['media']['track'][0]['Producer']
description = bwfMetadata['media']['track'][0]['Description']
date = bwfMetadata['media']['track'][0]['Encoded_Date']
sourcemedia = bwfMetadata['media']['track'][0]['Encoded_Library_Settings']
contact = 'https://www.lib.washington.edu/'

compressCommand = "flac -f --best --keep-foreign-metadata --preserve-modtime --verify #{target}"
tagCommand = "metaflac --preserve-modtime --set-tag=ORGANIZATION='#{organization}' --set-tag=DESCRIPTION='#{description}' --set-tag=DATE='#{date}' --set-tag=SOURCEMEDIA='#{sourcemedia}' --set-tag=CONTACT='#{contact}' #{flacPath}"

system(compressCommand)
system(tagCommand)
