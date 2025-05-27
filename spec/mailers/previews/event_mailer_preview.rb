# Preview all emails at http://localhost:3000/rails/mailers/event_mailer_mailer
class EventMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/event_mailer_mailer/event_finalized_notification
  def event_finalized_notification
    EventMailer.event_finalized_notification
  end

end
