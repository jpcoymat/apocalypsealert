class Product < ActiveRecord::Base
  belongs_to :organization
  validates :name, :code, :organization_id, presence: true
  validates_uniqueness_of :code, scope: :organization_id


end
