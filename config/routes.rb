Rails.application.routes.draw do
  get "/charts", to: "search#charts"
  get "/songs", to: "search#songs"
  get "/search/charts", to: "search#charts"
  get "/search/songs", to: "search#songs"

  get "/charts/:slug/:diff", to: "fetch#charts"

  get "/list/charts", to: "list#charts"
  get "/list/songs", to: "list#songs"
end
