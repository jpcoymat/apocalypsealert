class LocationGroup < ActiveRecord::Base

  belongs_to :organization
  has_many :locations


  validates :code, :name, presence: true
  validates :name, uniqueness: {scope: :organization_id}
  validates :code, uniqueness: {scope: :organization_id}

  def deleteable?
    locations.empty?
  end


end
