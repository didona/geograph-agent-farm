class StaticProfile < ActiveRecord::Base
  attr_accessible :duration, :dynamic_profile_id, :position
  acts_as_list :scope => :dynamic_profile
  has_many :agent_groups, :dependent => :destroy
  belongs_to :dynamic_profile
  has_one :static_profile

  class << self
    def max_position dynamic_profile_id
      joins(:dynamic_profile).where("dynamic_profiles.id = ?", dynamic_profile_id).maximum(:position) || 0
    end
  end

  def start
    Rails.logger.debug "Starting Static Profile"
    agent_groups.each do |g|
      g.deploy
    end

    agent_groups.each do |g|
      g.start
    end
  end

  def stop
    Rails.logger.debug "Stopping Static Profile"
    agent_groups.each do |g|
      g.shutdown
    end
  end
end
