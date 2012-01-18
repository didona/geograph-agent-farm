class Agent < ActiveRecord::Base
  #self.abstract_class = true
  
  before_destroy :destroy_remote
  include Madmass::AgentFarm::Agent::AutonomousAgent
  
  serialize :last_action, Hash
  belongs_to :agent_group
  belongs_to :position

  def on_error(exception)
    Madmass.logger.error exception
  end
  
  def destroy_remote
    Rails.logger.debug "REMOTE DESTROY #{self.geo_object}"
    execute(destroy_geo_object)
  end

  def reset
    self.position = nil
    save
  end
  
  private

  def create_geo_object
    {
      :agent => {:id => id},
      :cmd => 'actions::create',
      :latitude => 0,
      :longitude => 0,
      :data => {:type => self.type, :body => "Geo Object created at #{Time.now}"},
      :remote => true
    }
  end

  def destroy_geo_object
    {
      :agent => {:id => id},
      :cmd => 'actions::destroy',
      :geo_object => self.geo_object,
      :remote => true
    }
  end

  

end
