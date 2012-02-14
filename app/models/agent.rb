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

class Agent < ActiveRecord::Base
  #self.abstract_class = true
  
  before_destroy :destroy_remote
  include Madmass::AgentFarm::Agent::AutonomousAgent
  
  serialize :last_action, Hash
  belongs_to :agent_group
  belongs_to :position

  def on_error(ex)
    Madmass.logger.error ex
    Madmass.logger.error ex.backtrace.join("\n")
  end
  
  def destroy_remote
    execute(destroy_geo_object)
  end
  
  private

  def create_geo_object
    {
      :agent => {:id => id},
      :cmd => 'actions::create',
      :latitude => 0,
      :longitude => 0,
      :data => {:type => self.type, :body => "Geo Object created at #{Time.now}"},
      :remote => true
    }
  end

  def destroy_geo_object
    {
      :agent => {:id => id},
      :cmd => 'actions::destroy',
      :geo_object => self.geo_object,
      :remote => true
    }
  end

  

end
