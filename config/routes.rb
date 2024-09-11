Rails.application.routes.draw do
  get "/charts", to: "search#charts"
  get "/songs", to: "search#songs"

  get "/charts/:slug/:diff", to: "fetch#charts"
end
