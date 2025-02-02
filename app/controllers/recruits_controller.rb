# app/controllers/recruits_controller.rb
class RecruitsController < ApplicationController
  before_action :set_recruit, only: %i[show update destroy]
  before_action :set_current_dynasty, only: %i[create update]

  # GET /recruits
  def index
    @recruits = recruit.all
    render json: @recruits
  end

  # GET /recruits/:id
  def show
    render json: @recruit
  end

  # POST /recruits
  def create
    # Debugging the parameters received
    # Rails.logger.debug "Recruit params: #{recruit_params.inspect}"

    # Initialize the recruit
    @recruit = Recruit.new(recruit_params)

    # Debugging before assigning the dynasty
    # Rails.logger.debug "Current dynasty: #{@current_dynasty.inspect}"

    # Assign the dynasty to the recruit
    @recruit.dynasty = @current_dynasty

    # Debugging the recruit object before saving
    # Rails.logger.debug "Recruit before save: #{@recruit.inspect}"

    # Save the recruit
    if @recruit.save
      # Debugging successful save
      # Rails.logger.debug "Recruit saved successfully: #{@recruit.inspect}"
      render json: @recruit, status: :created
    else
      # Debugging save failure
      # Rails.logger.debug "Failed to save recruit: #{@recruit.errors.full_messages.inspect}"
      render json: { error: @recruit.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /recruits/:id
  def update
    Rails.logger.info("Updating recruit with ID: #{@recruit.id}")
    Rails.logger.info("Received params: #{recruit_params.inspect}")

    if @recruit.update(recruit_params)
      Rails.logger.info("Recruit updated successfully: #{@recruit.inspect}")
      render json: @recruit
    else
      Rails.logger.error("Failed to update recruit: #{@recruit.errors.full_messages}")
      render json: { error: @recruit.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /recruits/:id
  def destroy
    @recruit.destroy
    render json: { message: "recruit successfully deleted" }, status: :ok
  end

  def convert_to_player
    Rails.logger.debug "Starting the conversion of recruit to player"

    # Ensure that @recruit is fetched from the database using params[:id]
    @recruit = Recruit.find_by(id: params[:id])

    if @recruit.nil?
      Rails.logger.error "Recruit not found with ID: #{params[:id]}"
      render json: { error: "Recruit not found" }, status: :not_found
      return
    end

    # Log the incoming parameters
    Rails.logger.debug "Received parameters: overall=#{params[:overall]}, position=#{params[:position]}, dev_trait=#{params[:dev_trait]}, archetype=#{params[:archetype]}"

    begin
      # Perform the conversion to player
      @recruit.turn_into_player(
        overall: params[:overall],
        position: params[:position],
        dev_trait: params[:dev_trait],
        archetype: params[:archetype]
      )

      Rails.logger.debug "Successfully converted recruit #{@recruit.id} to player"
      render json: { message: "Recruit successfully converted to player" }, status: :ok
    rescue => e
      Rails.logger.error "Error converting recruit to player: #{e.message}"
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end



  private

  # Set the recruit for show, update, and destroy actions
  def set_recruit
    @recruit = Recruit.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "recruit not found" }, status: :not_found
  end

  # Set the current dynasty for the logged-in user
  def set_current_dynasty
    dynasty_id = session[:current_dynasty_id]
    if dynasty_id
      @current_dynasty = Dynasty.find(dynasty_id)
    else
      render json: { error: "No active dynasty found in session" }, status: :unprocessable_entity
    end
  end

  # Only allow a list of trusted parameters through
  def recruit_params
    params.require(:recruit).permit(
      :first_name,
      :last_name,
      :position,
      :archetype,
      :recruit_class,
      :athlete,
      :scouted,
      :gem,
      :bust,
      :recruiting_stage,
      :visit_week,
      :star_rating,
      :notes
    )
  end
end
