class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable,
         :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  has_many :organized_events, class_name: 'Event', foreign_key: 'admin_id'
  has_many :event_participants, foreign_key: 'user_id', dependent: :destroy
  has_many :participating_events, through: :event_participants, source: :event

  validates :name, presence: true
  validates :email, format: { 
    with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i,
    message: :invalid
  }
  validate :password_complexity
  validates :password, length: {
    minimum: 6,
    maximum: 128,
    too_short: I18n.t('activerecord.errors.models.user.attributes.password.too_short', count: 6),
    too_long: I18n.t('activerecord.errors.models.user.attributes.password.too_long', count: 128)
  }, if: -> { password.present? }

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

  def role=(value)
    value_str = value.to_s
    if self.class.roles.key?(value_str)
      super(value_str)
    else
      raise ArgumentError, I18n.t('activerecord.errors.models.user.attributes.role.invalid', value: value)
    end
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

    unless password.match?(/\d/)
      errors.add :password, :missing_number
    end
  end
end
