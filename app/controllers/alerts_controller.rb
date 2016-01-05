class AlertsController < ApplicationController
  before_action :set_alert, only: [:show, :edit, :update, :destroy]
  #take out this index for autheticate 
  #so you cant see lsit of alerts unless you're logged in 
  before_action :authenticate_user!, except: [:index]
  before_action :correct_user, only: [:show, :edit, :update, :destroy]
  
  # GET /alerts
  def index
    @alerts = Alert.all
  end

  # GET /alerts/1
  def show
  end

  # GET /alerts/new
  def new
    @alert = current_user.alerts.build
  end

  # GET /alerts/1/edit
  def edit
  end

  # POST /alerts
  def create
    @alert = current_user.alerts.build(alert_params)

    if @alert.save
      redirect_to @alert, notice: 'Alert was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /alerts/1
  def update
      if @alert.update(alert_params)
        redirect_to @alert, notice: 'Alert was successfully updated.'
      else
        render :edit
      end
  end

  # DELETE /alerts/1
  def destroy
    @alert.destroy
    redirect_to alerts_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_alert
      @alert = Alert.find(params[:id])
    end

    def correct_user
      @alert = current_user.alerts.find_by(id: params[:id])
      redirect_to alerts_path if @alert.nil?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def alert_params
      params.require(:alert).permit(:department,:course_number)
    end
end
