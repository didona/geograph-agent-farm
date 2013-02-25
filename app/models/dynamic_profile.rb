class DynamicProfile < ActiveRecord::Base
  validates_uniqueness_of :name
  attr_accessible :name, :user_id
  belongs_to :user
  belongs_to :benchmark_schedule
  has_many :static_profiles, :order => "position", :dependent => :destroy
end
