class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable,
         :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  validates :name, presence: true
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
end