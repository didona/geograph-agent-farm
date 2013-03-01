class BenchmarkSchedule < ActiveRecord::Base
  attr_accessible :user_id, :iterations
  has_many :dynamic_profiles, :order => "position"
  belongs_to :user
end
