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

class MapUpdater < Madmass::AgentFarm::Domain::AbstractUpdater
  include Madmass::Transaction::TxMonitor

  # Called by the AgentRunner MDB (in madmass) when an Agent must execute a step of its business logic.
  def run(perception)
    tx_monitor do
      # notify that a perception is received
      return unless agent = get_agent(perception)
      start_params = perception['data']
      agent.start start_params
    end

  rescue Exception => ex
    Madmass.logger.info "Error in run: #{ex}"
    Madmass.logger.info ex.backtrace.join("\n")
  end

  # Called by the PerceptionsProcessor when a perception is received. Update the agent status.
  def update_domain(perception)
    tx_monitor do
      # notify that a perception is received
      ActiveSupport::Notifications.instrument("geograph-generator.perception_received") unless perception['data'][:force]
      return unless agent = get_agent(perception)
      agent.set_last_action(perception)
    end

  rescue Exception => ex
    Madmass.logger.info "Error in update_domain: #{ex}"
    Madmass.logger.info ex.backtrace.join("\n")
  end


  private

  def get_agent(perception)
    agents = CloudTm::Agent.where(:id => perception['header']['agent_id'].to_i)

    if agents.blank?
      Madmass.logger.info "Cannot find agent with id: #{perception['header']['agent_id']}"
      return nil
    end

    agent  = agents.first

    if agent.getAgentGroup.blank?
      Madmass.logger.info "Cannot find agent group for agent with id: #{perception['header']['agent_id']}"
      return nil
    end

    agent
  end
end
