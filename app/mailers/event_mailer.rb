class EventMailer < ApplicationMailer
  include Rails.application.routes.url_helpers
  
  def event_finalized_notification(event)
    @event = event
    @admin = event.admin
    mail(to: @admin.email, subject: "Seu evento '#{@event.title}' foi finalizado.")
  end
end