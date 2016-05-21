class Alert < ActiveRecord::Base
	belongs_to :user

# returns list of departments to check from alerts
# using departments so that we only ping the server once per department page
# instead of once per alert 

	def self.get_departments
		depts = []

		Alert.all.each do |alert|
			depts.push(alert.department) unless depts.include?(alert.department)
		end
		return depts
	end

# checks for open seats in all classes that have alerts set 
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

			if department_seats[alert.course_number] #if the course number exists

				#parses the department_seats string from 'x of y' to x and y 
				registered = department_seats[alert.course_number].split[0].to_i
				seats = department_seats[alert.course_number].split[2].to_i

				if (registered < seats)
					open_seats[alert] = department_seats[alert.course_number] 
					puts "OpenSeats in #{alert.department} #{alert.course_number} for #{alert.user.email}"
				end
			end
		end

		open_seats.each do |alert , seats|
			AlertMailer.alert_email(alert).deliver_now
			alerts_sent << alert
			# alert.destroy (done in rake task now)
		end
		return alerts_sent
	end


private 

# takes mechanize agent, department code and term
# returns hash of section numbers to seats available 
# ex: 20 of 30 
	def self.fetch_dept_info(dept , agent, term)

		base_link = "http://classes.usc.edu/"
		page = agent.get(base_link + term + '/classes/' + dept)

		section_numbers = agent.page.search(".section").map(&:text).map(&:strip)
		seats = agent.page.search(".registered").map(&:text).map(&:strip)

		#removes the table headers
		section_numbers.delete_if do |section|
			if section == "Section"
				true
			else
				false
			end
		end

		#removes the table headers
		seats.delete_if do |seats|
			if seats == "Registered"
				true
			else
				false
			end
		end

		sections = Hash.new
		section_numbers.zip(seats).each do |number,seats|
			sections[number] = seats
		end

		return sections
	end

end
