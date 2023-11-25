Rails.application.routes.draw do
  get "/charts", to: "search#charts"
  get "/charts/:id", to: "fetch#charts"
  get "/songs", to: "search#songs"
  get "/songs/:id", to: "fetch#songs"
end
