# Rake task to check alerts and send out emails.
# Scheduled on Heroku scheduler

namespace :alerts do
	desc "Checks courses for open seats, check_seats defined in Alert model"
	task :check_alerts => :environment do
		alerts_sent = Alert.check_seats
		alerts_sent.each { |alert| alert.destroy}
	end

end