Rails.application.routes.draw do
  get "/charts", to: "search#charts"
  get "/songs", to: "search#songs"

  get "/charts/:slug/:diff", to: "fetch#charts"

  get "/v2/charts", to: "search#charts"
  get "/v2/songs", to: "search#songs"

  get "/v2/charts/:slug/:diff", to: "fetch#charts"
end
