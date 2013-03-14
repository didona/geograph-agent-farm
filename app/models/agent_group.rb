class AgentGroup < ActiveRecord::Base
  attr_accessible :simulator, :sleep, :static_profile_id, :threads, :cache_id
  belongs_to :static_profile
  include Madmass::Transaction::TxMonitor


  def deploy
    group_options ={"agents_type" => simulator, "delay" => sleep, "status" => "idle"}
    Madmass.logger.debug "DEPLOY: About to create group -- #{threads} agents #{group_options.inspect}--"

    tx_monitor do
      @agent_group = CloudTm::AgentGroup.create_group(threads, group_options)
      Madmass.logger.info "DEPLOY: Created agent group with id #{@agent_group.id} -- #{@agent_group.inspect}"
      self.cache_id = @agent_group.id
      save!
      Madmass.logger.debug "DEPLOY: Agentgroup Cache id saved"
    end

    tx_monitor do
      Madmass.logger.debug "DEPLOY: Retrieving agent group with cache id #{self.cache_id}"
      @agent_group = CloudTm::AgentGroup.find_by_id self.cache_id
      if @agent_group
        @agent_group.boot(:agent_group_id => self.cache_id)
      else
        Madmass.logger.error "DEPLOY: Could not find agent group #{self.cache_id}"
      end
    end
  end

  def start
    tx_monitor do
      agent_group = CloudTm::AgentGroup.find_by_id self.cache_id
      # agent_group.update_attribute(:status, 'started')
      Madmass.logger.debug "STARTING AGENT GROUP #{agent_group.inspect}"
      if agent_group
        agent_group.start
      else
        Madmass.logger.error "DEPLOY: Could not find agent group #{self.cache_id}"
      end

    end
  end

  def shutdown
    tx_monitor do
      Madmass.logger.debug "SHUTTING DOWN AGENT GROUP #{self.cache_id}"
      agent_group = CloudTm::AgentGroup.find_by_id self.cache_id
      ##terminates all the background tasks, one per each agent of the group
      if agent_group
        agent_group.shutdown
      else
        Madmass.logger.error "DEPLOY: Could not find agent group #{self.cache_id}"
      end

    end
  end


end
