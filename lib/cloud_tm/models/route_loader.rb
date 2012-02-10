module CloudTm
  module RouteLoader
    include Madmass::Transaction::TxMonitor
    
    def load_routes(gpx_path = nil)
        #Route.destroy_all
        gpx_path ||= Dir.glob(File.join(Rails.root, 'vendor', 'gpxs', '*.gpx'))
        gpx_path.each do |gpx|
          begin
            route = nil

            file = File.open(gpx)
            doc = Nokogiri::XML(file)
            rtes = doc.css("rte")
            trks = doc.css("trk")
            wpts = doc.css("wpt")
            #puts "rte: [#{rte.inspect}]"
            if !rtes.blank?
              rtes.each do |rte|
                route_name = rte.css("name").first.inner_text.capitalize
                route = retrieve_route(route_name)
                rte.css("rtept").each_with_index do |rtept, index|
                  position = CloudTm::Position.create(
                    :latitude => java.math.BigDecimal.new(rtept['lat']),
                    :longitude => java.math.BigDecimal.new(rtept['lon']),
                    :progressive => index
                  )
                  route.addPositions(position)

                end
                Rails.logger.info "Created route #{route.name} with #{route.getPositionsCount} positions."
              end
            elsif !trks.blank?
              trks.each do |trk|
                route_name = trk.css("name").first.inner_text.capitalize
                route = retrieve_route(route_name)
                trk.css("trkpt").each_with_index do |trkpt, index|
                  position = CloudTm::Position.create(
                    :latitude => java.math.BigDecimal.new(trkpt['lat']),
                    :longitude => java.math.BigDecimal.new(trkpt['lon']),
                    :progressive => index
                  )
                  route.addPositions(position)
                end
                Rails.logger.info "Created route #{route.name} with #{route.getPositionsCount} positions."
              end

            elsif !wpts.blank?
              route_name = doc.css("metadata").css("name").first.inner_text.capitalize
              route = retrieve_route(route_name)
              wpts.each_with_index do |wpt, index|
                position = CloudTm::Position.create(
                  :latitude => java.math.BigDecimal.new(wpt['lat']),
                  :longitude => java.math.BigDecimal.new(wpt['lon']),
                  :progressive => index
                )
                route.addPositions(position)
              end
              Rails.logger.info "Created route #{route.name} with #{route.getPositionsCount} positions."
            end

          ensure
            file.close
          end
        end

    end

    private

    def retrieve_route(name)
      route = CloudTm::Route.where(:name => name).first
      route = CloudTm::Route.create(:name => name) unless route
      #route.getPositions.clear
      route
    end

  end
end
