class ReaderAgent < Agent

  def set_last_action(perception)
    set = false
    case perception['header']['action']
    when 'actions::read_post_action'
      self.last_action['perception_status'] = perception['status']['code'] if(perception['status'] and perception['status']['code'])
      set = true
    end
    set
  end


  private

  def choose_action
    read_post
  end
  
  def read_post
    # rome
    lat = (rand * 0.196) + 41.794
    lon = (rand * 0.351) + 12.314
    {
      :agent => {:id => id},
      :cmd => 'actions::read_post',
      :latitude => lat,
      :longitude => lon,
      :remote => true
    }
  end

end
