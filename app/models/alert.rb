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
		term = "term-20163"

		agent = Mechanize.new

		depts.each do |dept|
			all_seats[dept] = fetch_dept_info(dept, agent, term)
		end

		Alert.all.each do |alert|
			department_seats = all_seats[alert.department]
			if (department_seats[alert.course_number] != "Registered" && department_seats[alert.course_number] != nil)
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

#takes agent that's already logged in and department code
#returns section numbers and seats available
#returns "Closed" in seat number if class is full 
	def self.fetch_dept_info(dept , agent, term)
		base_link = "http://classes.usc.edu/"
		page = agent.get(base_link + term + '/classes/' + dept)

		section_numbers = agent.page.search(".section").map(&:text).map(&:strip)
		registered = agent.page.search(".registered").map(&:text).map(&:strip)

		#removes the table headers 
		section_numbers.delete_if do |section|
			if section == "Section"
				true
			else
				false
			end
		end

		sections = Hash.new
		section_numbers.zip(registered).each do |number,registered|
			sections[number] = registered
		end

		return sections
	end

end
