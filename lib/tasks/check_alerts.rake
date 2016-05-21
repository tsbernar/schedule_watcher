# Rake task to check alerts and send out emails.
# Scheduled on Heroku scheduler

namespace :alerts do
	desc "Checks courses for open seats, check_seats defined in Alert model"
	task :check_alerts => :environment do

		alerts_sent = Alert.check_seats
		
		#remove alert (visable to user, and add to sent list record)
		alerts_sent.each do |alert| 
			@sent_list = SentList.new
			@sent_list.department = alert.department
			@sent_list.course_number = alert.course_number
			@sent_list.email = alert.user.email
			@sent_list.save
			alert.destroy
		end
	end
end