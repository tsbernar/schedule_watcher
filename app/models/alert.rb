class Alert < ActiveRecord::Base
	belongs_to :user

	def self.get_departments
		depts = []
		Alert.all.each do |alert|
			depts.push(alert.department) unless depts.include?(alert.department)
		end
		return depts
	end

	def self.check_seats
		depts = get_departments

		Alert.all.each do |alert|

		end
	end



	def fetch_dept_info(dept)
		id = "1545656529" 
		pw = "2537djuT"
		term = " Spring 2016"
		# This uses "Classic version" of web reg, 
		# should also try to implement on new version
		base_link = "https://camel2.usc.edu/webreg/crsesoffrd.asp?DEPT="
		agent = Mechanize.new
		page = agent.get('https://camel2.usc.edu/webreg/')
		form = page.form('LoginForm')
		form['Login::SSN'] = id
		form['Login::PIN'] = pw
		page = agent.submit(form)
		page = agent.page.link_with(:text => term).click
		page = agent.get(base_link + dept)


		section_numbers = agent.page.search(".sectiondata").map(&:text).map(&:strip)
		section_seats = agent.page.search(".seatsdata").map(&:text).map(&:strip)

		sections = Hash.new
		section_numbers.zip(section_seats).each do |number,seats|
			sections[number] = seats
			## puts number + " " + sections[number]
		end

		return sections
	end

end
