WeboSearch::Engine.routes.draw do
  resources :searches, only: :show
  root to: 'searches#show'
end
