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
  around_filter :transact
  
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

    @agent_group = CloudTm::AgentGroup.create_group(agents, group_options)
    @agent_group.boot #Starts a background tasks for each agent
    @agent_groups = CloudTm::AgentGroup.all
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

  def transact
    tx_monitor do
      yield
    end
  end
end
