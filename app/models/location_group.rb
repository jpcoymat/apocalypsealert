class LocationGroup < ActiveRecord::Base

  belongs_to :organization
  has_many :locations
  has_many :location_group_exceptions

  validates :code, :name, presence: true
  validates :name, uniqueness: {scope: :organization_id}
  validates :code, uniqueness: {scope: :organization_id}

end
