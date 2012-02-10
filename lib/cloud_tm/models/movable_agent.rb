module CloudTm
  class MovableAgent
    def set_last_action(perception)
      set_perception_status = false
      case perception['header']['action']
      when 'actions::create_action'
        self.geo_object = perception['data']['geo_object']
        set_perception_status = true
      when 'actions::move_action'
        if perception['status']['code'] == 'precondition_failed'
          self.geo_object = nil
        else
          self.latitude = java.math.BigDecimal.new(perception['data']['geo_object']['latitude'])
          self.longitude = java.math.BigDecimal.new(perception['data']['geo_object']['longitude'])
          set_perception_status = true
        end
      end

      if set_perception_status
        self.perception_status = perception['status']['code'] if(perception['status'] and perception['status']['code'])
      end

      set_perception_status
    end


    private


    def choose_action
      if geo_object
        return move_geo_object
      else
        return create_geo_object
      end
    end

    def move_geo_object
      return {} unless retrieve_route
      {
        :agent => {:id => id},
        :cmd => 'actions::move',
        :latitude => getPosition.latitude.to_s,
        :longitude => getPosition.longitude.to_s,
        :data => {:type => type, :body => "Geo Object moved at #{Time.now}"},
        :geo_object => geo_object,
        :remote => true
      }
    end

    def retrieve_route
      unless manager.getRoot.hasAnyRoutes
        # Load GPX routes
        CloudTm::Route.load_routes
      end

      next_position = nil
      if hasPosition
        current_position = getPosition
        # find the next position in the route
        current_position.getRoute.getPositions.each do |pos|
          if pos.progressive == current_position.progressive + 1
            next_position = pos
            break
          end
        end

#        next_position = Position.where("route_id = ? and progressive = ?", self.position.route_id, self.position.progressive + 1).first
      end

      unless next_position
        # select a random route
        routes = Route.all
        if routes.any?
          route = routes[rand(routes.size - 1)]
          next_position = route.getPositions.first
        end
      end

      if next_position
        setPosition(next_position)
      else
        getAgentGroup.stop
        return false
      end
      true
    end
  end
end 