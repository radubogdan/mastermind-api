class Api::GamesController < ApplicationController
  require 'digest/sha1'

  before_filter :generate_token, only: [:new]
  before_filter :check_game_token, only: [:create]
  after_filter :add_cors_in_header, only: [:new, :create]

  def new
    @game.generate_number
    @game.save
    render json: { mastermind: { game_token: @game.game_token } } 
  end

  def create
    if @game.validations(params[:guess])
      result = @game.generate_output(@game.number.to_s, params[:guess])
      @game.update_attributes(tries: @game.tries + 1)
      render json: { mastermind: { bulls: result[0], cows: result[1], tries: @game.tries } }
      if result[0] == 4
        @game.update_attributes(number: nil)
      end
    else
      render json: { mastermind: 'Invalid guess' }
    end
  end

  def show
    @game = Game.find_by_sql("SELECT name,tries FROM games WHERE number IS NULL ORDER BY tries ASC")
    render json: @game
  end

  private

  def check_game_token
    @game = Game.find_by_game_token(params[:game_token])
    unless @game
      render(:json => {errors: {record: ["Invalid Game Token"] } }, :status => 404)
    end
  end

  def generate_token
    @game = Game.new
    @game.game_token = SecureRandom.uuid
  end

  def add_cors_in_header
    headers['Access-Control-Allow-Origin'] = "*"
    headers['Access-Control-Request-Method'] = %w{GET POST OPTIONS}.join(",")
  end
end
