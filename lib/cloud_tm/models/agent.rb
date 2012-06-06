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


    def self.where_agent opts
      #Madmass.logger.info "Searching for agent group #{opts[:agent_group_id]}"
      group = CloudTm::AgentGroup.find(opts[:agent_group_id])
      unless group
        Madmass.logger.error "No agent group with id: #{opts[:agent_group_id]} found"
        Madmass.logger.error "All groups are: #{CloudTm::AgentGroup.all}"
        return nil
      end
     # Madmass.logger.info "Found group, looking for agent #{opts[:agent_id]}"
      group.getAgents.each do |agent|
        #Madmass.logger.info("Comparing #{agent.oid} == #{opts[:agent_id]} is #{agent.oid == opts[:agent_id]}")
        return agent if(agent.oid == opts[:agent_id])
      end
      Madmass.logger.error "Agent (#{opts[:agent_id]}) not found"
      return nil
    end

    def self.all_agents opts
      group = CloudTm::AgentGroup.find(opts[:agent_group_id])
      #Madmass.logger.info("Group is #{group.inspect}")
      group.getAgents
    end

    #TODO Old stuff refactor
    def destroy
      # destroy remote reference
      execute(destroy_geo_object)
      getAgentGroup.removeAgents(self)
      #manager.getRoot.removeAgents(self)
    end


    def inspect
      "<Agent(#{self.oid}), agent_type: '#{self.type}', status: '#{self.status}'>"
    end

    def last_execution_time_in_seconds
      self.last_execution ? (Time.now - Time.at(self.last_execution.getTime/1000)) : -1.0
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

      #def create_with_root attrs = {}, &block
      #  create_without_root(attrs) do |instance|
      #    instance.set_root manager.getRoot
      #  end
      #end

      #alias_method_chain :create, :root

      def all
        CloudTm::AgentGroup.all.map(&:getAgents).flatten
      end

    end
  end
end 