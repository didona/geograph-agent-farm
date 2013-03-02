class BenchmarkSchedule < ActiveRecord::Base
  attr_accessible :user_id, :iterations, :static_profile_id, :static_profile_progress, :active
  has_many :dynamic_profiles, :order => "position"
  belongs_to :static_profile
  belongs_to :user
end
