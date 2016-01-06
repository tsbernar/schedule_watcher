class AlertMailer < ApplicationMailer
	default from: 'trevor.s.bernard@gmail.com'

	def open_seats_email(alert)
		@alert = alert
		@user = @alert.user
		mail(to: @user.email, subject: "Open seats in your course!")
	end
end
