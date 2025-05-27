require_relative '../config/environment'
env :PATH, ENV['PATH']
set :output, "log/cron.log"
set :environment, Rails.env

every 1.day, at: '3:00 am' do
  runner "FinalizeExpiredEventsJob.perform_later"
end