class AgentGroup < ActiveRecord::Base
  has_many :agents, :dependent => :destroy
  
  validates :name, :uniqueness => true
  include AgentGroupState

  class << self

    def create_group(agents_count, options)
      group = create(options)
      agents_count.to_i.times do
        group.add_agent
      end
      group
    end

  end


  def modify(agent_count, attrs)
    update_attributes(attrs)
    if(agent_count > agents.count)
      # add agents
      (agent_count - agents.count).times do
        add_agent
      end
    elsif(agent_count < agents.count)
      # remove agents
      to_delete = agents.count - agent_count - 1
      agents[0..to_delete].each(&:destroy)
    end
  end

  def start
    queue = TorqueBox::Messaging::Queue.new('/queue/agents')
    agents.each do |agent|
      msg = {'header' => {'agent_id' => agent.id}, 'data' => {:force => true, :delay => delay}}
      queue.publish(msg, :tx => false)
      ActiveSupport::Notifications.instrument("geograph-generator.agent_queue_sent")
    end
    update_attribute(:status, 'started')
  end

  def stop
    agents.each do |agent|
      agent.stop
    end
    update_attribute(:status, 'stopped')
  end

  def pause
    agents.each do |agent|
      agent.pause
    end
    update_attribute(:status, 'paused')
  end


  def add_agent(agent_attrs = {})
    agent_klass = self.agents_type.constantize
    agents << agent_klass.new(agent_attrs)
  end
end

