@source_path = ARGV[0]
@destination_path = ARGV[1]
@limit = ARGV[2].to_i || 100

if @source_path.nil? or @destination_path.nil?
	puts "You must pass 2 params: a source path and a destination path!"
	exit(1)
end

unless File.exists?(@source_path)
	puts "Cannot find source path: #{@source_path}!"
	exit(1)
end

puts "Starting grabbing with source path: #{@source_path}, destination path: #{@destination_path} and limit: #{@limit}"

require 'nokogiri'
require 'fileutils'

FileUtils.mkdir_p(@destination_path)
xsd_path = File.join(File.dirname(__FILE__), 'gpx.xsd')
gpx_xsd = Nokogiri::XML::Schema(File.read(xsd_path))

count = 0
Dir.glob(File.join(@source_path, '*.gpx')).each do |gpx_path|
	begin
		gpx_file = File.open(gpx_path)
	  gpx_doc = Nokogiri::XML(gpx_file)
	  
	  if gpx_xsd.validate(gpx_doc).empty?
	    puts "#{gpx_path} is valid."
	    FileUtils.cp(gpx_path, @destination_path)
	    count += 1
	  else
	  	puts "#{gpx_path} is not valid."
	  end
	  if count == @limit
	  	puts "Finished: grabbed #{count} gpx routes."
	  	break
	  end
	rescue Exception => ex
		puts ex.message
	ensure
		gpx_file.close
	end
end