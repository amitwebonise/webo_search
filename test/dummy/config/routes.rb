Rails.application.routes.draw do

  mount WeboSearch::Engine => "/search"
end
