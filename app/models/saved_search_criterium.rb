class SavedSearchCriterium < ActiveRecord::Base

  belongs_to :organization
  
  serialize :search_parameters
  
  validates :name, :page, :search_parameters, :organization_id, presence: true
  
  validates :name, uniqueness: {scope: :organization_id}
  
  has_many :users
  

end
