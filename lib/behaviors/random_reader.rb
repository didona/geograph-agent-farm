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
  class RandomReader < Behaviors::RandomMover

    def next_action
      next_action = read_post(@current_route[@position_in_route])
      @position_in_route += 1
      @current_route = nil if @current_route[@position_in_route].nil?
      return next_action
    end

    # To change this template use File | Settings | File Templates.


    private
    def read_post(opts)
      # rome
      #lat = (rand * 0.196) + 41.794
      #lon = (rand * 0.351) + 12.314

      lat = opts[:latitude].to_s.to_f + (0.5 - rand) * 0.001
      lon = opts[:longitude].to_s.to_f + (0.5 - rand) * 0.001

      opts[:longitude]
      result = {
        :agent => {:id => @agent.oid},
        :cmd => 'actions::read_post',
        :latitude => lat,
        :longitude => lon,
        :remote => true
      }.merge(opts)
      return result
    end

  end
end
