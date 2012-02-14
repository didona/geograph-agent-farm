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

class MovableAgent < Agent

  def set_last_action(perception)
    set_perception_status = false
    case perception['header']['action']
    when 'actions::create_action'
      self.geo_object = perception['data']['geo_object']
      set_perception_status = true
    when 'actions::move_action'
      if perception['status']['code'] == 'precondition_failed'
        self.geo_object = nil
      else
        self.latitude = perception['data']['geo_object']['latitude']
        self.longitude = perception['data']['geo_object']['longitude']
        set_perception_status = true
      end
    end

    if set_perception_status
      self.last_action['perception_status'] = perception['status']['code'] if(perception['status'] and perception['status']['code'])
    end
    
    set_perception_status
  end

  
  private

  
  def choose_action
    if geo_object
      return move_geo_object
    else
      return create_geo_object
    end
  end
  
  def move_geo_object
    return {} unless retrieve_route
    {
      :agent => {:id => id},
      :cmd => 'actions::move',
      :latitude => self.position.latitude,
      :longitude => self.position.longitude,
      :data => {:type => self.type, :body => "Geo Object moved at #{Time.now}"},
      :geo_object => self.geo_object,
      :remote => true
    }
  end

  def retrieve_route
    if self.position
      # find the next position in the route
      next_position = Position.where("route_id = ? and progressive = ?", self.position.route_id, self.position.progressive + 1).first
    else
      # select a random route
      route = Route.all[rand(Route.count - 1)]
      next_position = route.positions.first
    end
    if next_position
      self.position = next_position
      save
    else
      agent_group.stop
      return false
    end
    true
  end
  
end
