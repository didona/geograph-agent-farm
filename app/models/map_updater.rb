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
