class User < ActiveRecord::Base

	devise :database_authenticatable, :registerable, 
		   :recoverable, :rememberable, :trackable, :validatable

	has_many :pins, dependent: :destroy
	validates :name, presence: true 
end
