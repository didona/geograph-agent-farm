class MapUpdater < Madmass::AgentFarm::Domain::AbstractUpdater
  include Madmass::Transaction::TxMonitor
  
  def update_domain(perception)

    agent = nil
    start_params = {}
    
    tx_monitor do
      # notify that a perception is sent
      ActiveSupport::Notifications.instrument("geograph-generator.perception_received") unless perception['data'][:force]
      Madmass.logger.info "PERCEPTION: #{perception.inspect}"
      agent = Agent.where(:id => perception['header']['agent_id'])

      if agent.blank?
        Madmass.logger.info "Cannot find agent with id: #{perception['header']['agent_id']}"
        return
      end

      agent  = agent.first

      if agent.agent_group.blank?
        Madmass.logger.info "Cannot find agent group for agent with id: #{perception['header']['agent_id']}"
        return
      end

      is_perception = false
      start_params = {:delay => agent.agent_group.delay, :force => false}
      case perception['header']['action']
      when 'Actions::CreateAction'
        agent.geo_object = perception['data']['geo_object']
        is_perception = true
      when 'Actions::MoveAction'
        agent.latitude = perception['data']['geo_object']['latitude']
        agent.longitude = perception['data']['geo_object']['longitude']
        is_perception = true
      when 'Actions::PostAction'
        agent.geo_object = perception['data']['geo_agent']
        is_perception = true
      else
        start_params = perception['data']
      end


      # notify perception to the agent that send the command
      if is_perception
        agent.last_action['perception'] = perception 
        agent.save
      end
    end

    agent.start start_params
 
  rescue Exception => ex
    Madmass.logger.info "Error in update_domain: #{ex}"
    Madmass.logger.info ex.backtrace.join("\n")    
  end
end
