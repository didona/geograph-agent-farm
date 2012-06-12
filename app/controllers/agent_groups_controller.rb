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

class AgentGroupsController < ApplicationController
  include Madmass::Transaction::TxMonitor


  before_filter :authenticate_agent
  around_filter :tx_monitor, :except => :boot
  after_filter :boot, :only => [:create]
  respond_to :html, :js

  def index
    respond_with(@agent_groups = CloudTm::AgentGroup.all)
  end

  # It creates a group of idle agents.
  def create

    group_options = params[:agent_group].clone
    group_options[:delay] = group_options[:delay].to_i
    group_options[:status] = 'idle'
    agents = group_options.delete(:agents)
    Madmass.logger.info "CREATE: About to create group -- #{agents.inspect} / #{group_options.inspect}--"
    @agent_group = CloudTm::AgentGroup.create_group(agents, group_options)
    Madmass.logger.info "CREATE: Created agent group with id #{@agent_group.id} -- #{@agent_group.inspect}"

    @agent_group_id = @agent_group.id
    Madmass.logger.info "CREATE: Retrieving all groups"
    @agent_groups = CloudTm::AgentGroup.all
    Madmass.logger.info "CREATE: Responding"
    respond_with(@agent_group)
  end


#def update
#  group_options = params[:agent_group].clone
#  group_options[:delay] = group_options[:delay].to_i
#  group_options[:agents_type] = "#{group_options[:agents_type].classify}Agent"
#  agents = group_options.delete(:agents)
#  @agent_group = CloudTm::AgentGroup.where(:id => params[:id].to_i).first
#  @agent_group.modify(agents.to_i, group_options)
#  @agent_groups = CloudTm::AgentGroup.all
#  respond_with(@agent_group)
#end

  def destroy
    agent_group = CloudTm::AgentGroup.where(:id => params[:id]).first
    ##terminates all the background tasks, one per each agent of the group
    agent_group.shutdown

    @agent_groups = CloudTm::AgentGroup.all
  end

  def start
    agent_group = CloudTm::AgentGroup.where(:id => params[:id]).first
    # agent_group.update_attribute(:status, 'started')
    Madmass.logger.info "STARTING AGENT GROUP #{agent_group.inspect}"
    agent_group.start if agent_group
    @agent_groups = CloudTm::AgentGroup.all
  end

  def stop
    agent_group = CloudTm::AgentGroup.where(:id => params[:id]).first
    #agent_group.update_attributes(:status => 'stopped', :last_execution => nil) if agent_group
    agent_group.stop if agent_group
    @agent_groups = CloudTm::AgentGroup.all
  end

  def pause
    agent_group = CloudTm::AgentGroup.where(:id => params[:id]).first
    agent_group.update_attribute(:status, 'paused') if agent_group
    agent_group.pause if agent_group
    @agent_groups = CloudTm::AgentGroup.all
  end

  private

  def boot
    agents_ids = []
    delay = 5
    type = nil
    tx_monitor do
      agent_group = CloudTm::AgentGroup.find(@agent_group_id)
      unless agent_group
        message = "Did not find agent group with id (#{@agent_group_id})"
        Madmass.logger.error message
        raise Madmass::Errors::CatastrophicError.new message
      end
      delay = agent_group.delay
      type = agent_group.agents_type
      agent_group.getAgents.each do |agent|
        Madmass.logger.info "Found agent in group: #{agent.inspect}"
        agents_ids << agent.oid
      end
      #agent_group.boot #Starts a background tasks for each agent
    end

    Madmass.logger.info "Starting #{agents_ids.size} simulations"

    simulator_opts ={
      :tx => false,
      :persistent => false,
      #:priority => :critical
    }

    # scatter_time = 500 #half a second
    Madmass.logger.info("Type: #{type}")

    klass_name = "CloudTm::#{type}"

    klass = klass_name.constantize
    raise Madmass::Errors::CatastrophicError, "#{klass_name} does not include Madmass::AgentFarm::Agent::AutonomousAgent" unless klass.included_modules.include?(Madmass::AgentFarm::Agent::AutonomousAgent)

    agents_ids.each do |agent_id|

      klass.background(simulator_opts).simulate(
        {:agent_id => agent_id,
         :step => delay,
         :agent_group_id => @agent_group_id}
      )
      #java.lang.Thread.sleep(scatter_time);
      Madmass.logger.info("******* Agent(group:#{@agent_group_id} -- id:#{agent_id}) launched *******")
    end
  end
end