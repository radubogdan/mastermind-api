class Api::GamesController < ApplicationController
  before_filter :generate_token, only: [:new]
  before_filter :check_game_token, only: [:create, :destroy]

  def new
    @game.generate_number
    @game.save
    render json: { mastermind: [game_token: @game.game_token]}
  end

  def create
    if @game.validations(params[:input])
      result = @game.generate_output(@game.number.to_s, params[:input])
      @game.update_attributes(tries: @game.tries + 1)
      render json: { mastermind: [bulls: result[0], cows: result[1], tries: @game.tries] }
    else
      render json: { mastermind: 'Invalid guess' }
    end
  end

  def destroy

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
    @game.game_token = BCrypt::Password.create(Time.now.to_s)
  end
end
