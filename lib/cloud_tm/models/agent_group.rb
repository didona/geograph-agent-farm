module CloudTm
  class AgentGroup
    include CloudTm::Model
    include CloudTm::AgentGroupState

    def start
      queue = TorqueBox::Messaging::Queue.new('/queue/agents')
      getAgents.each do |agent|
        msg = {'header' => {'agent_id' => agent.id}, 'data' => {:force => true, :delay => delay}}
        queue.publish(msg, :tx => false)
        ActiveSupport::Notifications.instrument("geograph-generator.agent_queue_sent")
      end
      update_attribute(:status, 'started')
    end

    def stop
      getAgents.each do |agent|
        agent.stop
      end
      update_attribute(:status, 'stopped')
    end

    def pause
      getAgents.each do |agent|
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
      manager.getRoot.removeAgentGroups(self)
    end

    def add_agent(agent_attrs = {})
      agent_klass = "CloudTm::#{agents_type}".constantize
#      agent = agent_klass.new
#      agent_attrs.each do |_name, value|
#        agent.send("#{_name}=", value)
#      end
#      agent.type = agents_type
      agent = agent_klass.create(agent_attrs.merge(:type => agents_type))
      addAgents(agent)
    end

    def modify(agent_count, attrs)
      update_attributes(attrs)
      if(agent_count > getAgentsCount)
        # add agents
        (agent_count - getAgentsCount).times do
          add_agent
        end
      elsif(agent_count < getAgentsCount)
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
        _oid = oid.to_i
        all.each do |agent_group|
          return agent_group if agent_group.oid == _oid
        end
        return nil
      end
      
      def create_with_root attrs = {}, &block
        create_without_root(attrs) do |instance|
          instance.set_root manager.getRoot
        end
      end

      alias_method_chain :create, :root

      def all
        manager.getRoot.getAgentGroups
      end


      def create_group(agents_count, options)
        group = create(options)
        agents_count.to_i.times do
          group.add_agent
        end
        group
      end

    end
  end
end