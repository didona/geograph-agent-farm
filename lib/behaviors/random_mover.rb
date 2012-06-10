# Selects at random a GPX route, and executes it from the beginning to the end.
module Behaviors
  class RandomMover < Madmass::AgentFarm::Agent::Behavior

    def initialize(agent)

      #Madmass.logger.info "Random Mover: creating with  agent_id #{@agent.oid}"

      @agent = agent

      # Load GPX routes
      CloudTm::Route.load_routes

      @current_route = nil;
      @position_in_route = 0;
    end

    #Select a Random route
    def choose!
      routes = CloudTm::Route.all
      if routes.any?
        random_route_pos = rand(routes.size - 1)
        i = 0
        @current_route = nil
        routes.each do |r|
          if (i==random_route_pos)
            @current_route = extract_route(r)
            @position_in_route = 0;
            raise MadMass::Exception::CatastrophicError.new("Positions in route missing") if @current_route.include?(nil)
            #Madmass.logger.info("Found #{i}-th route}")
            break;
          end
          #Madmass.logger.info("#{i}-th path considered")
          i=i+1
        end
      else
        raise Madmass::Exception::CatastrophicError.new "No GPX routes available!"
      end

    end

    def defined?
      @current_route != nil
    end

    #Select the next action that moves from
    def next_action
      next_action = move_params(@current_route[@position_in_route])
      @position_in_route += 1
      @current_route = nil if @current_route[@position_in_route].nil?
      return next_action
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
      params = {
        :user => {:id => @agent.oid},
        :cmd => 'actions::move',
        :data => {:type => @agent.type, :body => "Geo Object moved at #{Time.now}"},
        #:geo_agent => geo_object,
        :remote => true
      }.merge(opts)
      puts "Move params #{params.inspect}"
      return params
    end
  end

end

