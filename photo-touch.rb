#!/usr/bin/ruby
# encoding: utf-8
#
# Script for changing photo creation timestamp (in EXIF metadata and filesystem)
# If you're using rvm, please run script as `ruby photo-touch.rb`
# Tested in ruby-2.6.2
#
# Install ExifTool: http://www.sno.phy.queensu.ca/~phil/exiftool/install.html
#
# You need next gems for script to work (use gem install gem_name)
#  * mini_exiftool  (note: you need the ExifTool library!)
#
# 2018, Kai Aprk. Use it freely under the MIT license.
#

require 'rubygems'
require 'find'               # For Find.find (walk a directory)
require 'fileutils'          # For FileUtils.touch (change file timestamps)
require 'mini_exiftool'      # Exif metadata editing
require 'date'               # For DateTime

# Find all jpegs in currrent directory, change timestamps to required
Find.find('../') do |f|
   if f.match(/(\.jpg|jpeg|jfif)\Z/i)
    photo = MiniExiftool.new(f)
    filename = File.basename(f)
    date = nil
    case filename
      when /\d{13}(.*?)(\.jpg|jpeg|jfif|gif)\Z/i
        # Epoch Time
        # 1552545808705-8.jpg
        # 1552545808705.jpg
        puts "catched #{filename} with digit13length"
        s_file = filename.split(".")[0].split("-")
        date = Time.at(s_file[0][0..9].to_i)
      when /\w_\d{8}_\d{6}(\.jpg|jpeg|jfif|gif)\Z/i
        # DateTime
        # IMG_20181213_194608.jpg
        puts "catched #{filename} with YYMMDD_HHMMSS"
        s_file = filename.split(".")[0].split("_")
        date = DateTime.parse("#{s_file[1]}T#{s_file[2]}+0900")
      when /\w_\d{8}_\d{6}_\d{3}(\.jpg|jpeg|jfif|gif)\Z/i
        # DateTime
        # IMG_20181213_194608_123.jpg
        puts "catched #{filename} with YYMMDD_HHMMSS_sss"
        s_file = filename.split(".")[0].split("_")
        date = DateTime.parse("#{s_file[1]}T#{s_file[2]}+0900")
    else
      puts "not matched #{filename} any regex" 
    end

    if !date.nil?
      puts "#{f}\t- #{filename}\t#{date}"                    # For debug purposes
      photo.date_time_original = date           # Change EXIF photo creation timestamp
      photo.save
    end
    # if you wanna update UpdateTime
    #FileUtils.touch f, :mtime => DateTime.current         # Change filesystem creation timestamp
   end
end
