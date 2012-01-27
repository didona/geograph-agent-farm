class BloggerAgent < Agent

  private

  def choose_action
    geo_post_object
  end
  
  def geo_post_object
    lat = (rand * 0.196) + 41.794
    lon = (rand * 0.351) + 12.314
    {
      :agent => {:id => id},
      :cmd => 'actions::post',
      # rome
      :latitude => lat,
      :longitude => lon,
      # world
#      :latitude => ((rand * 180) - 90),
#      :longitude => ((rand * 360) - 180),
      :data => {:type => self.type, :body => 'Some text from agent post'},
      :geo_agent => self.geo_object,
      :remote => true
    }
  end

  def destroy_geo_object
    {
      :agent => {:id => id},
      :cmd => 'actions::destroy_posts',
      :geo_agent => self.geo_object,
      :remote => true
    }
  end
end
