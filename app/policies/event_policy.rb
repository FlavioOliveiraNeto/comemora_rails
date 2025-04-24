class EventPolicy
  attr_reader :user, :event

  def initialize(user, event)
    @user = user
    @event = event
  end

  def create?
    user.present?
  end

  def show?
    event.admin?(user) || event.participant?(user)
  end

  def update?
    event.admin?(user)
  end

  def destroy?
    event.admin?(user)
  end

  def invite?
    event.admin?(user)
  end

  def join?
    event.participant_status(user) == 'invited'
  end

  def decline?
    event.participant_status(user) == 'invited'
  end

  def add_media?
    event.admin?(user) || event.accepted_participant?(user)
  end

  def leave?
    event.accepted_participant?(user)
  end

  def admin?
    event.admin?(user)
  end
end