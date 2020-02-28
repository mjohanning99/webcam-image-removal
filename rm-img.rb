=begin
Copyright 2019-2020 Marvin Johanning

This webcam image removal program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

RubyTldr is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
=end

<<-DOC
This program's main intent is to remove images taken during the dark by a specfic type of webcam.

Sample file name: Snapshot_1903201645.jpg
DOC

#!/bin/env ruby

require 'sun_times' #Gem that figures out at which time the sunset / sunrise occurred

files = Dir.glob("**/*.jpg") #Get all .jpg files from current folder and all subfolders
#Note: This could be done using a CLI as well, specifying each folder separately

files.each do |file| 
  sun_times = SunTimes.new
  
  #Approximate coördinates for Bielefeld; can be adjusted accordingly
  latitude  = 52.0
  longitude = 8.0
  
  #Remove all the unwanted guff from the file path, ending up with only the date information at the end of the file name
  file_data = file.scan(/[0-9]+\.jpg/).first.gsub(".jpg", "") 

  time_file = file_data[6..9].to_i #Extract the time from the date information
  date_y    = "20" + file_data[0..1] #Extract the year from the date information ...
  date_y    = date_y.to_i #... add a "20" in front and turn it into an integer (SunTimes is a tad daft and doesn't realise that a two-digit integer can be used for displaying a year as well)
  date_m    = file_data[2..3].to_i #Extract the month
  date_d    = file_data[4..5].to_i #Extract the day
  
  day = Date.new(date_y, date_m, date_d) #Create a new Date object
  Time.local(date_y, date_m, date_d).dst? #Check whether DST was observed on the specified day in the local time zone
  
  <<-DOC
  The following section is quite a mess, thus a longer comment here.
  
  As mentioned above, the SunTimes gem is a bit retarded (or I might be) and spews out the result of sun_times.set/.rise in UTC. 
  Since this is, quite obviously, not the correct time-zone for Germany, I had to bodge this a little; I created two different variables: one which holds the sunset time of the day the image was taken and one for the sunrise time. This is done by simply adding one hour (in the case of regular CET) and two hours (for CEST) to the value that sun_times.set/.rise yields.
  DOC
  
  #Sunset times
  sunset_no_dst = sun_times.set(day, latitude, longitude).hour + 1 
  sunset_dst    = sun_times.set(day, latitude, longitude).hour + 2 
      
  if sun_times.set(day, latitude, longitude).min >= 10 then
        sunset_no_dst = sunset_no_dst.to_s + "#{sun_times.set(day, latitude, longitude).min}"
        sunset_dst    = sunset_dst.to_s + "#{sun_times.set(day, latitude, longitude).min}"
  else
      sunset_no_dst   = sunset_no_dst.to_s  + "10"
      sunset_dst      = sunset_dst.to_s  + "10"
  end
  
  
  #Sunrise times
  sunrise_no_dst = sun_times.rise(day, latitude, longitude).hour + 1 
  sunrise_dst    = sun_times.rise(day, latitude, longitude).hour + 2 
    
  if sun_times.rise(day, latitude, longitude).min >= 10 then
        sunrise_no_dst = sunrise_no_dst.to_s + "#{sun_times.rise(day, latitude, longitude).min}"
        sunrise_dst    = sunrise_dst.to_s + "#{sun_times.rise(day, latitude, longitude).min}"
  else
      sunrise_no_dst   = sunrise_no_dst.to_s  + "10"
      sunrise_dst      = sunrise_dst.to_s  + "10"
  end
  
  
  case Time.local(date_y, date_m, date_d).dst? #Check whether DST was observed at specified date ...
  when true #... set sunset / sunrise variables to DST variants if that's the case ...
      sunset  = sunset_dst.to_i - 200
      sunrise = sunrise_dst.to_i + 300
  when false #... otherwise, use regular CET
      sunset  = sunset_no_dst.to_i - 111
      sunrise = sunrise_no_dst.to_i + 200 
  end

  puts "Das am #{date_d}.#{date_m}.#{date_y} um #{time_file} erstellte Bild #{file} wird gelöscht" if time_file <= sunrise  #Inform the user which images are being deleted
  
  puts "Das am #{date_d}.#{date_m}.#{date_y} um #{time_file} erstellte Bild #{file} wird gelöscht" if time_file >= sunset
  
  File.delete(file) if time_file.to_i <= sunrise.to_i || time_file.to_i >= sunset.to_i #Delete the image if it was taken before or at sunrise or after / at sunset
end
