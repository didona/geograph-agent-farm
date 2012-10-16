###############################################################################
###############################################################################
#
# This file is part of GeoGraph Agent Farm.
#
# Copyright (c) 2012 Algorithmica Srl
#
# GeoGraph Agent Farm is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# GeoGraph Agent Farm is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with GeoGraph Agent Farm.  If not, see <http://www.gnu.org/licenses/>.
#
# Contact us via email at info@algorithmica.it or at
#
# Algorithmica Srl
# Vicolo di Sant'Agata 16
# 00153 Rome, Italy
#
###############################################################################
###############################################################################

module CloudTm
  module RouteLoader
    include Madmass::Transaction::TxMonitor

    def load_routes(gpx_path = nil)
      unless FenixFramework.getDomainRoot.getApp.hasAnyRoutes
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
                 # Madmass.logger.info("loading position #{index}")
                  position = CloudTm::Position.create(
                    :latitude => java.math.BigDecimal.new(rtept['lat']),
                    :longitude => java.math.BigDecimal.new(rtept['lon']),
                    :progressive => index
                  )
                  route.addPositions(position)

                end
                Madmass.logger.info "Created route #{route.name} with #{route.getPositionsCount} positions."
              end
            elsif !trks.blank?
              trks.each do |trk|
                route_name = trk.css("name").first.inner_text.capitalize
                route = retrieve_route(route_name)
                trk.css("trkpt").each_with_index do |trkpt, index|
                  #Madmass.logger.info("loading position #{index}")
                  position = CloudTm::Position.create(
                    :latitude => java.math.BigDecimal.new(trkpt['lat']),
                    :longitude => java.math.BigDecimal.new(trkpt['lon']),
                    :progressive => index
                  )
                  route.addPositions(position)
                end
                Madmass.logger.info "Created route #{route.name} with #{route.getPositionsCount} positions."
              end

            elsif !wpts.blank?
              route_name = doc.css("metadata").css("name").first.inner_text.capitalize
              route = retrieve_route(route_name)
              wpts.each_with_index do |wpt, index|
                #Madmass.logger.info("loading position #{index}")
                position = CloudTm::Position.create(
                  :latitude => java.math.BigDecimal.new(wpt['lat']),
                  :longitude => java.math.BigDecimal.new(wpt['lon']),
                  :progressive => index
                )
                route.addPositions(position)
              end
              Madmass.logger.info "Created route #{route.name} with #{route.getPositionsCount} positions."
            end

          ensure
            file.close
          end
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

    #check http://www.gpsbabel.org/htmldoc-development/filter_interpolate.html
    #http://www.gpsbabel.org/htmldoc-development/index.html
    #def interpolate route
    #  Madmass.logger.info "interpolating route of size #{route.size}"
    #  path_step = 10*(1.0/111111.1) #10 meters
    #  new_route = []
    #  route.each_with_index do |pos, index|
    #    new_route << pos
    #    break if ((route.size-1) == index)
    #    next_pos = route[index+1]
    #    current = pos
    #
    #
    #    while (dist(current, next_pos)< path_step)
    #      delta_y = next_pos['lat'].to_f-pos['lat'].to_f
    #      delta_x = next_pos['lon'].to_f-pos['lon'].to_f
    #      angle = Math.atan2(delta_y, delta_x)
    #      current = {
    #        'lat' => current['lat'].to_f+path_step*Math.sin(angle),
    #        'lon' => current['lon'].to_f+path_step*Math.cos(angle)
    #      }
    #      new_route << current
    #      #y = ya + ((x - xa) * (yb - ya) / (xb - xa))  (pos['lat'] + next_pos['lat']
    #    end
    #
    #  end
    #  Madmass.logger.info "new size is #{new_route.size}"
    #  Madmass.logger.info "*****************************"
    #  return new_route
    #end
    #
    #def dist(pos, next_pos)
    #  delta_y = next_pos['lat'].to_f-pos['lat'].to_f
    #  delta_x = next_pos['lon'].to_f-pos['lon'].to_f
    #  return Math.sqrt(delta_x*delta_x+delta_y*delta_y)
    #end


  end
end
