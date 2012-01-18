class MovableAgent < Agent

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
      :latitude => self.position.latitude,
      :longitude => self.position.longitude,
      :data => {:type => self.type, :body => "Geo Object moved at #{Time.now}"},
      :geo_object => self.geo_object,
      :remote => true
    }
  end

  def retrieve_route
    if self.position
      # find the next position in the route
      next_position = Position.where("route_id = ? and progressive = ?", self.position.route_id, self.position.progressive + 1).first
    else
      # select a random route
      route = Route.all[rand(Route.count - 1)]
      next_position = route.positions.first
    end
    if next_position
      self.position = next_position
      save
    else
      agent_group.stop
      return false
    end
    true
  end
  
end
