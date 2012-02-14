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
  module AgentGroupState
    def state_attributes
      {
        :started => started?,
        :stopped => stopped?,
        :idle => idle?,
        :paused => paused?
      }
    end

    def started
      "started"
    end

    def started?
      status == started
    end

    def stopped
      "stopped"
    end

    def stopped?
      status == stopped
    end

    def idle
      "idle"
    end

    def idle?
      status == idle
    end

    def paused
      "paused"
    end

    def paused?
      status == paused
    end

    def possible_actions
      case status
      when started
        ["destroy", "pause", "stop"]
      when stopped
        ["start", "destroy"]
      when paused
        ["start", "destroy"]
      when idle
        ["start", "destroy"]
      else
        ["destroy"]
      end
    end
  end
end