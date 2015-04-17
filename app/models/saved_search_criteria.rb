class SavedSearchCriteria < ActiveRecord::Base

  belongs_to :organization
  
  serialize :parameters
  
  validates :name, :filter_name, :parameters, :organization_id, presence: true
  
  validates :name, uniqueness: {scope: :organization_id}

end
