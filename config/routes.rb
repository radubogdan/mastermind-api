Mastermind::Application.routes.draw do
  namespace(:api, defaults: {format: 'json'}) do
    resources :games, only: [:new, :create, :destroy]
  end
end
