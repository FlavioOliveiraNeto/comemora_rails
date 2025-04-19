class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable,
         :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  validates :name, presence: true
  validate :password_complexity
  enum role: { guest: 'guest', admin: 'admin' }

  after_initialize :set_default_role, if: :new_record?

  def jwt_payload
    {
      user_id: id,
      role: role,
      email: email,
      exp: 24.hours.from_now.to_i 
    }
  end

  private

  def set_default_role
    self.role ||= :guest
  end

  def password_complexity
    return if password.blank?
  
    unless password.match?(/[A-Z]/)
      errors.add :password, :missing_uppercase
    end
  
    unless password.match?(/[!@#$%^&*(),.?":{}|<>]/)
      errors.add :password, :missing_special_char
    end
  end
end