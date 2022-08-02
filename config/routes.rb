Rails.application.routes.draw do
  root "search#all"
  get "/songs", to: "search#songs"
end
