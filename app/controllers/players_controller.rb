# app/controllers/players_controller.rb
class PlayersController < ApplicationController
  before_action :set_player, only: %i[show update destroy]
  before_action :set_current_dynasty, only: %i[create update]

  # GET /players
  def index
    @players = Player.all
    render json: @players
  end

  # GET /players/:id
  def show
    render json: @player
  end

  # POST /players
  def create
    @player = Player.new(player_params)
    @player.dynasty = @current_dynasty

    if @player.save
      render json: @player, status: :created
    else
      render json: { error: @player.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /players/:id
  def update
    if @player.update(player_params)
      render json: @player
    else
      render json: { error: @player.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /players/:id
  def destroy
    @player.destroy
    render json: { message: "Player successfully deleted" }, status: :ok
  end

  private

  # Set the player for show, update, and destroy actions
  def set_player
    @player = Player.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Player not found" }, status: :not_found
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
  def player_params
    params.require(:player).permit(
      :first_name,
      :last_name,
      :class_year,
      :position,
      :archetype,
      :overall,
      :dev_trait,
      :redshirted,
      :current_redshirt
    )
  end
end
