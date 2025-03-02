class DynastiesController < ApplicationController
  before_action :set_dynasty, only: %i[show update destroy ]
  before_action :sweat_current_dynasty, only: %i[get_current_dynasty current_dynasty_players current_dynasty_recruits advance_class_years clear_graduates clear_roster clear_recruits bulk_update_players bulk_update_redshirt bulk_convert_to_players delete_selected_players graduate_seniors]

  # GET /dynasties
  def index
    logger.debug "Current User: #{current_user.inspect}"
    @dynasties = current_user.dynasties
    render json: @dynasties
  end

  # GET /dynasties/:id
  def show
    render json: @dynasty
  end

  # POST /dynasties
  def create
    @dynasty = current_user.dynasties.new(dynasty_params)

    if @dynasty.save
      render json: @dynasty, status: :created
    else
      render json: { error: @dynasty.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /dynasties/:id
  def update
    if @dynasty.update(dynasty_params)
      render json: @dynasty
    else
      render json: { error: @dynasty.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /dynasties/:id
  def destroy
    @dynasty.destroy
    render json: { message: "Dynasty deleted successfully" }
  end

  # Sets the current dynasty
  def set_current_dynasty
    Rails.logger.debug "Params received: #{params.inspect}" # Debug log
    dynasty = Dynasty.find_by(id: params[:id])

    if dynasty && dynasty.user_id == current_user.id
      session[:current_dynasty_id] = dynasty.id
      render json: { message: "Current dynasty updated", dynasty: dynasty }, status: :ok
    else
      render json: { error: "Dynasty not found or unauthorized" }, status: :not_found
    end
  end

  # Retrieves the current dynasty for the user
  # GET /dynasties/current
  def get_current_dynasty
    if @current_dynasty
      render json: @current_dynasty
    else
      render json: { error: "No current dynasty found" }, status: :not_found
    end
  end

  # Retrieves players for the current dynasty
  def current_dynasty_players
    if @current_dynasty
      @players = @current_dynasty.players
      render json: @players
    else
      render json: { error: "No active dynasty found" }, status: :unprocessable_entity
    end
  end

  def current_dynasty_recruits
    if @current_dynasty
      @recruits = @current_dynasty.recruits
      render json: @recruits
    else
      render json: { error: "No active dynasty found" }, status: :unprocessable_entity
    end
  end

  # PUT /dynasties/advance_class_years
  def advance_class_years
    # Ensure we have the current dynasty
    if @current_dynasty
      # Iterate through all players in the current dynasty
      failed_players = []

      @current_dynasty.players.each do |player|
        unless player.advance_class_year
          failed_players << player
        end
      end

      if failed_players.any?
        render json: { error: "Failed to update some players", players: failed_players.map(&:id) }, status: :unprocessable_entity
      else
        @current_dynasty.update(year: @current_dynasty.year + 1)
        render json: { message: "All players class years advanced" }, status: :ok
      end
    else
      render json: { error: "No active dynasty found" }, status: :unprocessable_entity
    end
  end

  def clear_graduates
    if @current_dynasty
      # Delete all players where class_year is 'Graduate'
      graduates = @current_dynasty.players.where(class_year: "Graduate")
      graduates.destroy_all

      render json: { message: "#{graduates.count} graduates cleared from the roster" }, status: :ok
    else
      render json: { error: "No active dynasty found" }, status: :unprocessable_entity
    end
  end

  def graduate_seniors
    if @current_dynasty
      # Find all seniors who are currently redshirted
      seniors = @current_dynasty.players.where(class_year: "Senior", current_redshirt: false)

      # Destroy all found seniors
      seniors.destroy_all

      render json: { message: "#{seniors.count} non-redshirted seniors graduated and cleared from the roster" }, status: :ok
    else
      render json: { error: "No active dynasty found" }, status: :unprocessable_entity
    end
  end

  def clear_roster
    if @current_dynasty
      roster = @current_dynasty.players
      roster.destroy_all

      render json: { message: "Roster cleared" }, status: :ok
    else
      render json: { error: "No active dynasty found" }, status: :unprocessable_entity
    end
  end

  def clear_recruits
    if @current_dynasty
      recruits = @current_dynasty.recruits
      recruits.destroy_all

      render json: { message: "Recruits cleared" }, status: :ok
    else
      render json: { error: "No active dynasty found" }, status: :unprocessable_entity
    end
  end

  def bulk_update_players
    if @current_dynasty
      begin
        updated_count = 0

        @current_dynasty.players.transaction do
          params[:players].each do |player_params|
            player = @current_dynasty.players.find(player_params[:id])

            if player.update!(overall: player_params[:overall], position: player_params[:position], archetype: player_params[:archetype])
              updated_count += 1
            end
          end
        end

        render json: {
          message: "Successfully updated #{updated_count} players' overalls, positions, and archetypes",
          updated_count: updated_count
        }, status: :ok

      rescue ActiveRecord::RecordNotFound => e
        render json: { error: "Could not find one or more players" }, status: :not_found
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    else
      render json: { error: "No active dynasty found" }, status: :unprocessable_entity
    end
  end

  def bulk_update_redshirt
    if @current_dynasty
      begin
        updated_count = 0

        @current_dynasty.players.transaction do
          params[:players].each do |player_params|
            player = @current_dynasty.players.find(player_params[:id])

            # Update only the current_redshirt attribute
            if player.update!(current_redshirt: player_params[:current_redshirt])
              updated_count += 1
            end
          end
        end

        render json: {
          message: "Successfully updated #{updated_count} players' current_redshirt status",
          updated_count: updated_count
        }, status: :ok

      rescue ActiveRecord::RecordNotFound => e
        render json: { error: "Could not find one or more players" }, status: :not_found
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    else
      render json: { error: "No active dynasty found" }, status: :unprocessable_entity
    end
  end

  def bulk_convert_to_players
    if @current_dynasty
      begin
        converted_count = 0

        @current_dynasty.recruits.transaction do
          params[:recruits].each do |recruit_params|
            recruit = @current_dynasty.recruits.find(recruit_params[:id])

            # Pass recruit details to turn_into_player method
            if recruit.turn_into_player(
              overall: recruit_params[:overall],
              position: recruit_params[:position],
              dev_trait: recruit_params[:dev_trait],
              archetype: recruit_params[:archetype]
            )
              converted_count += 1
            end
          end
        end

        render json: {
          message: "Successfully converted #{converted_count} recruits to players",
          converted_count: converted_count
        }, status: :ok

      rescue ActiveRecord::RecordNotFound => e
        render json: { error: "Could not find one or more recruits" }, status: :not_found
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    else
      render json: { error: "No active dynasty found" }, status: :unprocessable_entity
    end
  end


  def delete_selected_players
    if @current_dynasty
      begin
        deleted_count = 0

        @current_dynasty.players.transaction do
          params[:player_ids].each do |player_id|
            player = @current_dynasty.players.find(player_id)
            player.destroy
            deleted_count += 1
          end
        end

        render json: {
          message: "Successfully deleted #{deleted_count} players",
          deleted_count: deleted_count
        }, status: :ok

      rescue ActiveRecord::RecordNotFound => e
        render json: { error: "Could not find one or more players with the provided IDs" }, status: :not_found
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    else
      render json: { error: "No active dynasty found" }, status: :unprocessable_entity
    end
  end

  private

  # Find and set the current dynasty based on session
  def sweat_current_dynasty
    Rails.logger.info "Session Data: #{session.to_hash}"
    dynasty_id = session[:current_dynasty_id]
    if dynasty_id
      @current_dynasty = Dynasty.find_by(id: dynasty_id)
    else
      render json: { error: "No active dynasty found in session" }, status: :unprocessable_entity
    end
  end

  # Find and set the dynasty for the show, update, and destroy actions
  def set_dynasty
    @dynasty = current_user.dynasties.find_by(id: params[:id])
    render json: { error: "Dynasty not found" }, status: :not_found unless @dynasty
  end

  # Strong parameters for creating and updating dynasties
  def dynasty_params
    params.require(:dynasty).permit(:dynasty_name, :school_name, :year)
  end
end
