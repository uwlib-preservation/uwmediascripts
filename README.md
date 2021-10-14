# UW Media Scripts

**batchbext.rb**
  - Tool for batch embedding the metadata settings stored in the `uwmetaedit2` config file into multiple WAV files. Relies on UW's preferred naming convention to parse corrctly.
  
**bwf2flac.rb**
   - Tool for batch converting BWF files to FLAC files. Extracts BEXT metadata and maps to Vorbis comments while updating associated CUE sheets with new output file names.
 
**caption-embed.rb**
  - Facilitates the inclusion of VTT caption files into MP4s, either through embedding or inclusion in the video.

**compare_times.rb** 
  - Compares log files created by `get_cd_meta.rb` to target WAV files to confirm complete capture of optical media.

**get_cd_meta.rb** 
  - Creates logfiles containing the length of each audio CD inserted into target drive while script is looping. Used in combination with `compare_times.rb`

**rename-waves.rb**
  - Used to batch rename WAV files (in order of file creation time).

**uwmetaedit2**
  - Used to embed BWF metadata into WAV files
  - Requires ruby 'flammarion' gem and a version of Chrome browser to be installed.
