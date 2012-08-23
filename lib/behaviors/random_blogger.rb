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

require "#{Rails.root}/lib/behaviors/random_mover"

module Behaviors
  class RandomBlogger < Behaviors::RandomMover
    def initialize
      super
    end

    def next_action
      next_action = geo_post_object(@current_route[@position_in_route])
      @position_in_route += 1
      @current_route = nil if @current_route[@position_in_route].nil?
      return next_action
    end

    private

    def geo_post_object opts

      lat = opts[:latitude].to_s.to_f+(0.5-rand) * 0.05
      lon = opts[:longitude].to_s.to_f+(0.5-rand) * 0.05

      return {
        :cmd => "madmass::action::remote",
        :data => {
          :cmd => 'actions::post',
          # rome
          :latitude => lat,
          :longitude => lon,
          :data => {
            :type => "Post",
            :body => "Post from Blogger\n, Coordinates <#{lon},#{lat}>"},
          :user => {:id => @agent.oid}
        }#.merge(opts)
      }

      Madmass.logger.debug "Behaviors::RandomBlogger created post action: \n #{result.to_yaml}\n"
      return result;
    end

    #FIXME OLD STUFF to RESTORE
    def destroy_geo_object
      {
        :cmd => 'actions::destroy_posts',
        :geo_agent => geo_object,

      }
    end

  end
end