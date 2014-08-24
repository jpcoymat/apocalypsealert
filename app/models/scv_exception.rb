class ScvException < ActiveRecord::Base

  belongs_to :affected_object, polymorphic: true
  belongs_to :cause_object, polymorphic: true

  enum status: [ :open, :closed, :archived]
  
  validates :type, :priority, :status, :affected_object_id, :affected_object_type, :cause_object_id, :cause_object_type, presence: true

  def self.priorities
    @@priorities = [1,2,3]
  end

  def self.types
    @@types = ["Quantity", "Date"]
  end

  


end
