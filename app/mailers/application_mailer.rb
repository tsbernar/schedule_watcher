class ApplicationMailer < ActionMailer::Base
  default from: "usc.schedule.watcher@gmail.com"
  layout 'mailer'
end
