Rails.application.routes.draw do
  get "/charts", to: "search#charts"
  get "/songs", to: "search#songs"

  get "/charts/:slug_diff", to: "fetch#charts"

  get "/v2/charts", to: "search#charts", defaults: { version: "v2" }
  get "/v2/songs", to: "search#songs", defaults: { version: "v2" }

  get "/v2/charts/:slug/:diff", to: "fetch#charts_v2"
end
