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
  class MovableAgent
    def set_last_action(perception)
      set_perception_status = false
      case perception['header']['action']
        when 'actions::create_action'
          self.geo_object = perception['data']['geo_object']['id']
          set_perception_status = true
        when 'actions::move_action'
          if perception['status']['code'] == 'precondition_failed'
            self.geo_object = nil
          else
            self.geo_object = perception['data']['geo_agent']
            self.latitude = java.math.BigDecimal.new(perception['data']['geo_object']['latitude'])
            self.longitude = java.math.BigDecimal.new(perception['data']['geo_object']['longitude'])
            set_perception_status = true
          end
      end

      if set_perception_status
        self.perception_status = perception['status']['code'] if (perception['status'] and perception['status']['code'])
      end

      set_perception_status
    end


    private


    def choose_action
      move_geo_object
    end

    def move_geo_object
      return {} unless retrieve_route
      {
        :user => {:id => id},
        :cmd => 'actions::move',
        :latitude => getPosition.latitude.to_s,
        :longitude => getPosition.longitude.to_s,
        :data => {:type => type, :body => "Geo Object moved at #{Time.now}"},
        #:geo_agent => geo_object,
        :remote => true
      }
    end

    def retrieve_route
      unless manager.getRoot.hasAnyRoutes
        # Load GPX routes
        CloudTm::Route.load_routes
      end

      next_position = nil
      if hasPosition
        current_position = getPosition
        # find the next position in the route
        current_position.getRoute.getPositions.each do |pos|
          if pos.progressive == current_position.progressive + 1
            next_position = pos
            break
          end
        end
      end

      unless next_position
        # select a random route
        routes = Route.all
        if routes.any?

          random_route_pos = rand(routes.size - 1)
          i = 0
          route = nil
          routes.each do |r|
              if(i==random_route_pos)
                route= r
                #Madmass.logger.info("Found #{i}-th route}")
                break;
              end
              #Madmass.logger.info("#{i}-th path considered")
               i=i+1
          end
         # route = routes[]
          next_position = route.getPositions.first
        end
      end

      if next_position
        setPosition(next_position)
      else
        getAgentGroup.stop
        return false
      end
      true
    end
  end
end 