class Milestone < ActiveRecord::Base


  validates :reference_number, :associated_object_type, :associated_object_id, presence: true

  belongs_to :associated_object, polymorphic: true

  def customer_organization
    @customer_organization = Organization.find(self.customer_organization_id)
  end

  def customer_organization=(organization)
    self.customer_organization_id = organization.try(:id)
  end

  def customer_organization_name
    customer_organization.try(:name)
  end

  def customer_organization_name=(organization_name)
    self.customer_organization_id = Organization.where(name: organization_name).first.try(:id)
  end
 
  def create_organization
    @create_organization = Organization.find(self.create_organization_id)
  end

  def create_organization=(organization)
    self.create_organization_id = organization.try(:id)
  end

  def create_organization_name
    create_organization.try(:name)
  end

  def create_organization_name=(organization_name)
    self.create_organization_id = Organization.where(name: organization_name).first.try(:id)
  end

  def create_user
    @create_user = User.find(self.create_user_id)
  end

  def create_user=(user)
    self.create_user_id = user.try(:id)
  end

 
 


end
