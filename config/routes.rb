WeboSearch::Engine.routes.draw do
  resources :searches, only: :show do
    collection do
      get :lookup
    end
  end
  root to: 'searches#show'
end
