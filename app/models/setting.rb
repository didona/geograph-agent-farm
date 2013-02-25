class Setting < ActiveRecord::Base
  attr_accessible :map_url, :stats_url, :user_id
  belongs_to :user
end
