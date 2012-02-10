module CloudTm
  class BloggerAgent

    def set_last_action(perception)
      set = false
      case perception['header']['action']
      when 'actions::post_action'
        Rails.logger.debug "BLOGGER AGENT IS MY ACTION: geo_object: #{perception['data']['geo_agent']} - perc_status: #{perception['status']['code']}"
        self.geo_object = perception['data']['geo_agent']
        self.perception_status = perception['status']['code'] if(perception['status'] and perception['status']['code'])
        set = true
      end
      set
    end


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
        :data => {:type => type, :body => 'Some text from agent post'},
        :geo_agent => geo_object,
        :remote => true
      }
    end

    def destroy_geo_object
      {
        :agent => {:id => id},
        :cmd => 'actions::destroy_posts',
        :geo_agent => geo_object,
        :remote => true
      }
    end
    
  end
end 