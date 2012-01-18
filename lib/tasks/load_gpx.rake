namespace :agent_farm do
  desc "Load all gpx routes stored in tmp/gpxs folder."
  task :load_gpxs => :environment do
    gpxs = Dir.glob(File.join(Rails.root, 'vendor', 'gpxs', '*.gpx'))
    gpxs.each do |gpx|
      route = nil
      
      file = File.open(gpx)
      doc = Nokogiri::XML(file)
      rtes = doc.css("rte")
      #puts "rte: [#{rte.inspect}]"
      unless rtes.blank?
        rtes.each do |rte|
          route_name = rte.css("name").first.inner_text.capitalize
          route = retrieve_route(route_name)
          rte.css("rtept").each_with_index do |rtept, index|
            route.positions.create(
              :latitude => rtept['lat'],
              :longitude => rtept['lon'],
              :progressive => index
            )
          end
          puts "Created route #{route.name} with #{route.positions.size} positions."
        end
      else
        trks = doc.css("trk")
        trks.each do |trk|
          route_name = trk.css("name").first.inner_text.capitalize
          route = retrieve_route(route_name)
          trk.css("trkpt").each_with_index do |trkpt, index|
            route.positions.create(
              :latitude => trkpt['lat'],
              :longitude => trkpt['lon'],
              :progressive => index
            )
            #puts "#{rtept.css('time').inner_text} - #{rtept['lat']} - #{rtept['lon']}"
          end
          puts "Created route #{route.name} with #{route.positions.size} positions."
        end
      end

      file.close
    end
  end

  private

  def retrieve_route(name)
    route = Route.where(:name => name).first
    route = Route.create(:name => name) unless route
    route.positions.clear
    route
  end
end