class Route < ActiveRecord::Base
  has_many :positions, :order => "progressive"
  validates :name, :uniqueness => true
end
