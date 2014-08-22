class Location < ActiveRecord::Base


  belongs_to :organization
  belongs_to :location_group

  validates :name, :code, :city, :country, presence: true
  validates_uniqueness_of :code, scope: :organization_id



end
