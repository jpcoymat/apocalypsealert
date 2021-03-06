class User < ActiveRecord::Base

  validates :first_name, :last_name, :email, :organization_id, :encrypted_password, presence: true

  validates     :username, length: {:within => 3..40}
  validates     :username, uniqueness: true
  validates     :password, confirmation: true
  validate      :password_must_be_present

  belongs_to :organization
  
  belongs_to :saved_search_criterium

  def full_name
    self.first_name + " " + self.last_name
  end

  def password_must_be_present
    errors.add(:password, "Missing password" ) unless encrypted_password.present?
  end

  def password
    @password
  end

  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    self.encrypted_password = Digest::SHA1.hexdigest(self.password)
  end

  def password_must_be_present
    errors.add(:password, "Missing password" ) unless encrypted_password.present?
  end


  def self.authenticate(username, password)
    user = User.where(username: username).first
    unless user.nil?
      expected_password = Digest::SHA1.hexdigest(password)
      if user.encrypted_password != expected_password
        user = nil
      end
    end
    user
  end



end
