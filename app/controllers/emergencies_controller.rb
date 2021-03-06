class EmergenciesController < ApplicationController
  def index
    emergencies = Emergency.all.map { |e| e.as_json root: false }
    full_responses = [
      Emergency.where(full_response: true).count,
      Emergency.count
    ]
    render json: { emergencies: emergencies, full_responses: full_responses }
  end

  def create
    @emergency = Emergency.new(emergency_create_params)
    @emergency.save!
    dispatch_responders(@emergency)
    render json: @emergency, root: true, status: 201
  rescue ActiveRecord::RecordInvalid
    render json: { 'message' => @emergency.errors.messages }, status: 422
  rescue ActionController::UnpermittedParameters => e
    render json: { 'message' => e.message }, status: 422
  end

  def show
    @emergency = Emergency.find_by(code: params[:code])
    if @emergency
      render json: @emergency, root: true
    else
      routing_error
    end
  end

  def update
    @emergency = Emergency.find_by(code: params[:code])
    @emergency.update!(emergency_update_params)
    render json: @emergency, root: true, status: 200
  rescue ActiveRecord::RecordInvalid
    render json: { 'message' => @emergency.errors.messages }, status: 422
  rescue ActionController::UnpermittedParameters => e
    render json: { 'message' => e.message }, status: 422
  end

  private

  def emergency_create_params
    params.require(:emergency).permit(:code, :fire_severity, :police_severity, :medical_severity)
  end

  def emergency_update_params
    params.require(:emergency).permit(:resolved_at, :fire_severity, :police_severity, :medical_severity)
  end
end
