#!/usr/bin/env ruby

require 'optparse'
require 'fileutils'

options = []
@exluded_numbers = []
ARGV.options do |opts|
  opts.on('-s', '--start=val', Integer) { |val| Start = val }
  opts.on('-e', '--end=val', Integer) { |val| End = val }
  opts.on('-x', '--exclude=val', Integer) { |val| @exluded_numbers << val }
  opts.parse!
end

target_dir = ARGV[0]
images = Dir.glob("#{target_dir}/*.[Jj][Pp][Gg]")
imagesSorted = images.sort_by {|filename| File.mtime(filename) }
target_numbers = (Start .. End).to_a - @exluded_numbers

if ! defined?(images) || images.empty?
  puts "Please add directory containing image files!"
  exit
elsif target_numbers.count != imagesSorted.count
  puts "Number of images and new file names doesn't match! Please check inputs."
  exit
end

imagesSorted.each_with_index do |image,index|
  newName = File.dirname(image) + '/' + target_numbers[index].to_s + '.jpg'
  unless File.exist?(newName)
    FileUtils.mv(image,newName)
  else
    puts "File #{newName} already exists! Skipping!"
  end
end
