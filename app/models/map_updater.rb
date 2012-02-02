class MapUpdater < Madmass::AgentFarm::Domain::AbstractUpdater
  include Madmass::Transaction::TxMonitor

  def update_domain(perception)
    delay = 0
    tx_monitor do
      # notify that a perception is received
      ActiveSupport::Notifications.instrument("geograph-generator.perception_received") unless perception['data'][:force]
      agents = Agent.where(:id => perception['header']['agent_id'])

      if agents.blank?
        Madmass.logger.info "Cannot find agent with id: #{perception['header']['agent_id']}"
        return
      end

      agent  = agents.first

      if agent.agent_group.blank?
        Madmass.logger.info "Cannot find agent group for agent with id: #{perception['header']['agent_id']}"
        return
      end

      start_params = {:force => false}

      unless agent.set_last_action(perception)
        # the request come from agent group start
        start_params = perception['data']
      end

      agent.save
      agent.start start_params
      
      delay = agent.agent_group.delay
    end
    sleep(delay)
    
  rescue Exception => ex
    Madmass.logger.info "Error in update_domain: #{ex}"
    Madmass.logger.info ex.backtrace.join("\n")
  end

end
