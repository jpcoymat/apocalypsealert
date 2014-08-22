class Organization < ActiveRecord::Base

  has_many :locations
  has_many :location_groups
  has_many :products
  has_many :users


end
