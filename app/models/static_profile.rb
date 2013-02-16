class StaticProfile < ActiveRecord::Base
  attr_accessible :duration, :dynamic_profile_id, :position
  acts_as_list :scope => :dynamic_profile
  has_many :agent_groups, :dependent => :destroy
end
