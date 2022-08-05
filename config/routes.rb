Rails.application.routes.draw do
  root "pages#home"
  get "/charts", to: "search#charts"
  get "/songs", to: "search#songs"
end
