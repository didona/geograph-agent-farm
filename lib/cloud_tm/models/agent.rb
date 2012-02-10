module CloudTm
  class Agent
    include CloudTm::Model
    include Madmass::AgentFarm::Agent::AutonomousAgent

    def destroy
      # destroy remote reference
      execute(destroy_geo_object)
      getAgentGroup.removeAgents(self)
      manager.getRoot.removeAgents(self)
    end

    def on_error(ex)
      Madmass.logger.error ex
      Madmass.logger.error ex.backtrace.join("\n")
    end
  
    private

    def create_geo_object
      {
        :agent => {:id => id},
        :cmd => 'actions::create',
        :latitude => 0,
        :longitude => 0,
        :data => {:type => type, :body => "Geo Object created at #{Time.now}"},
        :remote => true
      }
    end

    def destroy_geo_object
      {
        :agent => {:id => id},
        :cmd => 'actions::destroy',
        :geo_object => geo_object,
        :remote => true
      }
    end

    class << self

      def create_with_root attrs = {}, &block
        create_without_root(attrs) do |instance|
          instance.set_root manager.getRoot
        end
      end

      alias_method_chain :create, :root
      
      def all
        manager.getRoot.getAgents
      end

    end
  end
end 