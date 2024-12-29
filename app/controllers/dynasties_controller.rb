class DynastiesController < ApplicationController
  before_action :set_dynasty, only: %i[show update destroy ]
  before_action :sweat_current_dynasty, only: %i[get_current_dynasty current_dynasty_players current_dynasty_recruits advance_class_years]

  # GET /dynasties
  def index
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

  private

  # Find and set the current dynasty based on session
  def sweat_current_dynasty
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
