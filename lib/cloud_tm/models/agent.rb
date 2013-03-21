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


    def self.find_by_id opts
      #Madmass.logger.info "Searching for agent group #{opts[:agent_group_id]}"

      agent = FenixFramework.getDomainObject(opts[:agent_id])
      Madmass.logger.error "Agent (#{opts[:agent_id]}) not found" unless agent
      return agent
    end


    #TODO Old stuff refactor
    def destroy
      # destroy remote reference
      execute(destroy_geo_object)
      getAgentGroup.removeAgents(self)
      #manager.getRoot.removeAgents(self)
    end


    def inspect
      "<Agent(#{self.getExternalId}), agent_type: '#{self.type}', status: '#{self.status}'>"
    end



    private

    #def create_geo_object
    #  {
    #    :agent => {:id => id},
    #    :cmd => 'actions::create',
    #    :latitude => 0,
    #    :longitude => 0,
    #    :data => {:type => type, :body => "Geo Object created at #{Time.now}"},
    #    :remote => true
    #  }
    #end

    def destroy_geo_object
      {
        :agent => {:id => id},
        :cmd => 'actions::destroy',
        :geo_object => geo_object,
        :remote => true
      }
    end

    class << self

      #def create_with_root attrs = {}, &block
      #  create_without_root(attrs) do |instance|
      #    instance.set_root manager.getRoot
      #  end
      #end

      #alias_method_chain :create, :root

      def all
        CloudTm::AgentGroup.all.map(&:getAgents).flatten
      end

      private

    end
  end
end