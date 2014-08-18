Rails.application.routes.draw do
  root to: 'home#welcome'
  get '/results', to: 'home#results'
end
