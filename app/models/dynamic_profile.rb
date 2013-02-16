class DynamicProfile < ActiveRecord::Base
  attr_accessible :name, :user_id
  belongs_to :user
  has_many :static_profiles, :order => "position", :dependent => :destroy
end
