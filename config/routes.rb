Rails.application.routes.draw do
  get "/search/charts", to: "search#charts"
  get "/search/songs", to: "search#songs"

  get "/fetch/charts/:slug/:diff", to: "fetch#charts"

  get "/list/charts", to: "list#charts"
  get "/list/songs", to: "list#songs"
end
