class DynamicProfile < ActiveRecord::Base
  validates_uniqueness_of :name
  attr_accessible :name, :user_id, :iterations, :current_iteration
  belongs_to :user
  belongs_to :benchmark_schedule
  acts_as_list :scope => :benchmark_schedule
  has_many :static_profiles, :order => "position", :dependent => :destroy

  class << self
	  def max_position benchmark_schedule_id
	  	joins(:benchmark_schedule).where("benchmark_schedules.id = ?", benchmark_schedule_id).maximum(:position) || 0
	  end
	end
end
