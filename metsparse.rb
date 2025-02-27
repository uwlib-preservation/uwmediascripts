require 'nokogiri'

def parseMETS(input)
  fileManifest = []
  metsXML =  Nokogiri::XML(File.read(input))
  metsXML.remove_namespaces!
  files = metsXML.xpath("//originalName")
  files.each {|file| fileManifest << "\t" + File.basename(file.inner_text)}
  fileManifest[0].strip!
  fileManifest << "\n"
end

target = ARGV[0]
outputArray = []
@metsManifests = Dir.glob("#{target}/*.xml")


outputArray = []
@metsManifests.sort.each {|mets| outputArray << parseMETS(mets)}

File.open("#{target}/File-list.txt", "w+") do |f|
  outputArray.each { |line| f.puts(line) }
end
