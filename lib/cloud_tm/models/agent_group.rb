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

require File.join(File.dirname(__FILE__), 'agent_group_state')


module CloudTm
  class AgentGroup
    include CloudTm::Model
    include CloudTm::AgentGroupState
    include Madmass::Transaction::TxMonitor
    include TorqueBox::Messaging::Backgroundable

    always_background :undertaker


    def shutdown

      #Send the shutdown signal
      getAgents.each do |agent|
        agent.shutdown
        Madmass.logger.info("******* #{agent.inspect} shutting down  *******")
      end

      undertaker
    end

    def start(options = {})
      getAgents.each do |agent|
        #Madmass.logger.info("******* #{agent.inspect} before start *******")
        agent.play
        #Madmass.logger.info("******* #{agent.inspect}  start running*******")
      end

      update_attributes(:status => 'started', :last_execution => java.util.Date.new)
    end


    #FIXME: refactor, OLD CODE starts here

    def stop
      getAgents.each do |agent|
        agent.stop
        Madmass.logger.info("******* #{agent.inspect} stopping *******")
      end
      update_attribute(:status, 'stopped')
    end

    def pause
      getAgents.each do |agent|
        Madmass.logger.info("******* #{agent.inspect} pausing *******")
        agent.pause
      end
      update_attribute(:status, 'paused')
    end

    def attributes_to_hash
      {
        :id => id,
        :name => name,
        :agents_type => agents_type,
        :delay => delay,
        :agents_count => getAgentsCount,
      }
    end

    def to_json
      attributes_to_hash.to_json
    end


    def destroy
      FenixFramework.getDomainRoot.getApp.removeAgentGroups(self)
    end

    def add_agent(agent_attrs = {})
      agent_klass = "CloudTm::#{self.agents_type}".constantize
      agent_attributes = agent_attrs.merge(:type => self.agents_type)
      Madmass.logger.debug "Agent attributes: #{agent_attributes}"
      agent = agent_klass.create(agent_attributes)
      agent.status = 'stopped'

      Madmass.logger.debug "CREATED #{agent.inspect}"
      addAgents(agent)
      Madmass.logger.debug "#{agent.inspect} ADDED to group #{self.inspect}"
    end

    def modify(agent_count, attrs)
      update_attributes(attrs)
      if (agent_count > getAgentsCount)
        # add agents
        (agent_count - getAgentsCount).times do
          add_agent
        end
      elsif (agent_count < getAgentsCount)
        # remove agents
        to_delete = getAgentsCount - agent_count - 1
        getAgents[0..to_delete].each(&:destroy)
      end
    end

    def inspect
      {:name => name, :agents_type => agents_type, :delay => delay}.inspect
    end

    class << self

      def find(oid)
        _oid = oid
        all.each do |agent_group|
          return agent_group if agent_group.oid == _oid
        end
        return nil
      end

      def create_with_root attrs = {}, &block
        create_without_root(attrs) do |instance|
          instance.set_root FenixFramework.getDomainRoot().getApp
        end
      end

      alias_method_chain :create, :root

      def all
        #Madmass.logger.info("IN ALL  Manager is #{manager}")
        # Madmass.logger.info("IN ALL  Root is #{manager.getRoot}")
        # Madmass.logger.info("IN ALL  Root oid is #{manager.getRoot.oid}") if manager.getRoot
        FenixFramework.getDomainRoot.getApp.getAgentGroups
      end

      #
      def create_group(agents_count, options)
        #Creates the group and its agents on the DSTM
        group = create(options)
        agents_count.to_i.times do
          group.add_agent
        end
        group
      end

    end
    private

    #Cleans up the group when all agents are dead
    def undertaker
      #Thread.new do
        #Destroy groups' data *ONLY* after all agents have shutdown!
        Madmass.logger.debug "Undertaker started"
        all_agents = nil
        dead_agents = nil
        begin
          java.lang.Thread.sleep(delay/2.0)
          #TorqueBox::transaction(:requires_new => true) do
          tx_monitor do
            agents=getAgents
            all_agents = agents.size
            tmp = agents.find_all { |a| a.status == 'dead' }
            zombies = agents.find_all { |a| a.status == 'zombie' }
            dead_agents = tmp.size
            Madmass.logger.debug("Undertaker: alive #{all_agents} -- zombies #{zombies.size} -- dead--> #{dead_agents}")
            #Madmass.logger.info("Undertaker: agents are #{agents.size} of which dead #{dead_agents.size}")
            #end
          end
        end while (all_agents != dead_agents)


        #TorqueBox::transaction(:requires_new => true) do
        tx_monitor do
          destroy
        end
        #end


        Madmass.logger.debug "******* Agent group burried! *********"
     # end
    end
  end
end