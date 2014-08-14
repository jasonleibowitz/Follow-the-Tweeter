Rails.application.routes.draw do
  root to: 'home#welcome'
  post '/results', to: 'home#results'
end
