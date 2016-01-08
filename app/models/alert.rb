class Alert < ActiveRecord::Base
	belongs_to :user

# returns list of departments to check from alerts
	def self.get_departments
		depts = []
		Alert.all.each do |alert|
			depts.push(alert.department) unless depts.include?(alert.department)
		end
		return depts
	end

# Sends emails to users of alerts that have open seats
# Returns array of alerts that have been sent (to be deleted)
	def self.check_seats
		depts = get_departments
		all_seats = Hash.new
		open_seats = Hash.new
		alerts_sent = []

		agent = login

		depts.each do |dept|
			all_seats[dept] = fetch_dept_info(dept, agent)
		end

		Alert.all.each do |alert|
			department_seats = all_seats[alert.department]
			if (department_seats[alert.course_number] != "Closed" && department_seats[alert.course_number] != nil)
				open_seats[alert] = department_seats[alert.course_number] 
			end
		end
		open_seats.each do |alert , seats|
			AlertMailer.alert_email(alert).deliver_now
			alerts_sent << alert
			# alert.destroy (done in rake task now)
		end

		alerts_sent
	end


private 

#logs in using mechanize agent, returns agent to keep browsing session data
	def self.login
		id = ENV["ID"]
		pw = ENV["PW"]
		term = " Spring 2016"

		agent = Mechanize.new
		page = agent.get('https://camel2.usc.edu/webreg/')
		form = page.form('LoginForm')
		form['Login::SSN'] = id
		form['Login::PIN'] = pw
		page = agent.submit(form)
		page = agent.page.link_with(:text => term).click

		return agent
	end

#takes agent that's already logged in and department code
#returns section numbers and seats available
#returns "Closed" in seat number if class is full 
	def self.fetch_dept_info(dept , agent)
		base_link = "https://camel2.usc.edu/webreg/crsesoffrd.asp?DEPT="
		page = agent.get(base_link + dept)

		section_numbers = agent.page.search(".sectiondata").map(&:text).map(&:strip)
		section_seats = agent.page.search(".seatsdata").map(&:text).map(&:strip)

		sections = Hash.new
		section_numbers.zip(section_seats).each do |number,seats|
			sections[number] = seats
		end

		return sections
	end

end
