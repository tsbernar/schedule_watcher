class AlertsController < ApplicationController
	before_action :set_alert, only: [:show, :edit, :update, :destroy]
	before_action :correct_user, only: [:edit, :update, :destroy]
	before_action :authenticate_user!, except: [:index, :show]
	
	def index
		@alerts = Alert.all.order("created_at DESC")
	end

	def show
	end

	def new
		@alert = current_user.alerts.build
	end

	def edit
	end

	def create
		@alert = current_user.alert.build(alert_params)
		if @alert.save
			redirect_to @alert, notice: 'Alert was successfully created.'
		else
			render action: 'new'
		end
	end

	def update
		if @alert.update(alert_params)
			redirect_to @alert, notice: 'Alert was successfully updated'
		else
			render action: 'edit'
		end
	end

	def destroy
		@alert.destroy
		redirect_to alerts_url
	end

	private

	def set_alert
		@alert = Alert.find(params[:id])
	end

	def correct_user
		@alert = current_user.alerts.find_by(id: params[:id])
		redirect_to alerts_path, notice: "Not autorized to edit this alert"
	end

	def alert_params
		params.require(:alert).permit(:section_number, :seats, :department)
	end

end
