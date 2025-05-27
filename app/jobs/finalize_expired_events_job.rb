class FinalizeExpiredEventsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Event.where('end_date < ?', Time.current).where(status: :active).each do |event|
      if event.update(status: :finished)
        Rails.logger.info "Evento '#{event.title}' (ID: #{event.id}) finalizado automaticamente. Enviando notificação ao administrador."
        EventMailer.event_finalized_notification(event).deliver_now
      else
        Rails.logger.error "Falha ao finalizar automaticamente o evento '#{event.title}' (ID: #{event.id})."
      end
    end
  end
end