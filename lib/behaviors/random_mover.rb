# Selects at random a GPX route, and executes it from the beginning to the end.
module Behaviors
  class RandomMover < Madmass::AgentFarm::Agent::Behavior

    def initialize
      @current_route = nil
      @position_in_route = 0
    end

    # Select a Random route
    def choose!
      routes = CloudTm::Route.all
      if routes.any?
        random_route_pos = rand(routes.size - 1)
        routes.each_with_index do |route, index|
          if(index == random_route_pos)
            @current_route = extract_route(route)
            @position_in_route = 0
            raise MadMass::Errors::CatastrophicError.new("Positions in route missing") if (@current_route.include?(nil))
            break
          end
        end
      else
        raise Madmass::Errors::CatastrophicError.new "No GPX routes available!"
      end
    end

    def defined?
      return @current_route != nil
    end

    #Select the next action that moves from
    def next_action
      action = move_params(@current_route[@position_in_route])
      if (@position_in_route < @current_route.size - 1)
        @position_in_route += 1
      else
        @current_route = nil
      end
      return action
    end

    def last_wish
      destroy_agent_params
    end


    private


    def extract_route dml_route
      route = []
      #FIXME: interpolate routes
      dml_route.getPositions.each do |pos|
        route[pos.progressive] = {
          :latitude => pos.latitude.to_s,
          :longitude => pos.longitude.to_s
        }
      end
      return route;
    end

    def move_params opts
      return {
        :cmd => "madmass::action::remote",
        :data => {
          :cmd => 'track_current',
          :data => {
            :type => "Mover",
            :body => "Mover with position\n <#{opts[:latitude].to_s}, #{opts[:longitude].to_s}>"
          },
          :sync => true,
          :user => {:id => @agent.id}
        }.merge(opts)
      }
    end

    def destroy_agent_params(opts = {})
      return {
        :cmd => "madmass::action::remote",
        :data => {
          :cmd => 'destroy_agent',
          :sync => true,
          :user => {:id => @agent.id}
        }.merge(opts)
      }
    end

  end

end

