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
  class Agent
    include CloudTm::Model
    include Madmass::AgentFarm::Agent::AutonomousAgent

    ##TODO move in autonomous agent
    #always_background :boot
    #
    ##TODO move in autonomous agent
    #def boot
    #  update_attributes :status, 'running'
    #  perception = nil
    #  delay = 1*2000 #TODO hack, remove me
    #  until status == 'killed'
    #    perception = execute_step(perception) unless status == 'stopped' or status == 'paused'
    #    puts "agent id: #{id}"
    #    java.lang.Thread.sleep(delay);
    #  end
    #end
    #
    ##TODO move in autonomous agent
    #def shutdown
    #  update_attributes :status, 'killed'
    #end

    def destroy
      # destroy remote reference
      execute(destroy_geo_object)
      getAgentGroup.removeAgents(self)
      manager.getRoot.removeAgents(self)
    end

    def on_error(ex)
      Madmass.logger.error ex
      Madmass.logger.error ex.backtrace.join("\n")
    end

    private

    def create_geo_object
      {
        :agent => {:id => id},
        :cmd => 'actions::create',
        :latitude => 0,
        :longitude => 0,
        :data => {:type => type, :body => "Geo Object created at #{Time.now}"},
        :remote => true
      }
    end

    def destroy_geo_object
      {
        :agent => {:id => id},
        :cmd => 'actions::destroy',
        :geo_object => geo_object,
        :remote => true
      }
    end

    class << self

      def create_with_root attrs = {}, &block
        create_without_root(attrs) do |instance|
          instance.set_root manager.getRoot
        end
      end

      alias_method_chain :create, :root

      def all
        manager.getRoot.getAgents
      end

    end
  end
end 