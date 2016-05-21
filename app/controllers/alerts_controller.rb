# Class for handling user created alerts
class AlertsController < ApplicationController
  before_action :set_alert, only: [:show, :edit, :update, :destroy]
  before_action :correct_user, only: [:show, :edit, :update, :destroy]

  # GET /alerts
  def index
    @alerts = current_user.alerts if user_signed_in?
  end

  # GET /alerts/new
  def new
    @alert = current_user.alerts.build
    # Client token generated for braintree payment form 
    @client_token = Braintree::ClientToken.generate
  end

  # GET /alerts/1/edit
  def edit
  end

  # POST /alerts
  def create
    # use current_user build to create user alert relationship
    nonce = payment_method_nonce_params
    # maybe remove action: below 
    render :new and return unless nonce

    @alert = current_user.alerts.build(alert_params) 

    result = Braintree::Transaction.sale(amount: "2.00", payment_method_nonce: nonce, 
      custom_fields: {
      email: current_user.email,
      department: @alert.department,
      course_number: @alert.course_number
    })

    if result.success? and @alert.save
      redirect_to alerts_path, notice: 'Alert was successfully created.'
      AlertMailer.set_alert_email(@alert).deliver_now
    else
      render :new, notice: "Error with payment, try agian"
    end
  end

  # PATCH/PUT /alerts/1
  def update
    if @alert.update(alert_params)
      redirect_to alerts_path, notice: 'Alert was successfully updated.'
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

  # only allow the approved params
  def alert_params
    params.require(:alert).permit(:department, :course_number)
  end

  def payment_method_nonce_params
    params.require(:payment_method_nonce)
  end

end
