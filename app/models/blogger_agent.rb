class BloggerAgent < Agent

  private

  def choose_action
    geo_post_object
  end
  
  def geo_post_object
    {
      :agent => {:id => id},
      :cmd => 'actions::post',
      :latitude => rand(100),
      :longitude => rand(100),
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
