class AgentGroup < ActiveRecord::Base
  attr_accessible :simulator, :sleep, :static_profile_id, :threads
  belongs_to :static_profile
end
