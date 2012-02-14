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

  def update_domain(perception)
    delay = 0
    tx_monitor do
      # notify that a perception is received
      ActiveSupport::Notifications.instrument("geograph-generator.perception_received") unless perception['data'][:force]
      agents = CloudTm::Agent.where(:id => perception['header']['agent_id'].to_i)

      if agents.blank?
        Madmass.logger.info "Cannot find agent with id: #{perception['header']['agent_id']}"
        return
      end

      agent  = agents.first

      if agent.getAgentGroup.blank?
        Madmass.logger.info "Cannot find agent group for agent with id: #{perception['header']['agent_id']}"
        return
      end

      Rails.logger.debug "AGENT: #{agent.id} - #{agent.status} - #{agent.geo_object}"
      #Rails.logger.debug "PERCEPTION: #{perception.inspect}"
      
      start_params = {:force => false}

      unless agent.set_last_action(perception)
        # the request come from agent group start
        start_params = perception['data']
      end

      
      agent.start start_params
      
      delay = agent.getAgentGroup.delay
    end
    sleep(delay)
    
  rescue Exception => ex
    Madmass.logger.info "Error in update_domain: #{ex}"
    Madmass.logger.info ex.backtrace.join("\n")
  end

end
