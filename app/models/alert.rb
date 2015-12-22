class Alert < ActiveRecord::Base
	belongs_to :user

	validates :section_number, presence: true
	validates :department, presence: true
end
