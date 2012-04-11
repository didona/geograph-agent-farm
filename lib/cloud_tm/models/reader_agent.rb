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
  class ReaderAgent
    def set_last_action(perception)
      set = false
      case perception['header']['action']
      when 'actions::read_post_action'
        self.perception_status = perception['status']['code'] if(perception['status'] and perception['status']['code'])
        set = true
      end
      set
    end


    private

    def choose_action
      read_post
    end

    def read_post
      # rome
      lat = (rand * 0.196) + 41.794
      lon = (rand * 0.351) + 12.314
      {
        :agent => {:id => id},
        :cmd => 'actions::read_post',
        :latitude => lat,
        :longitude => lon,
        :remote => true
      }
    end
  end
end 