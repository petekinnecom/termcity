defmodule TcCacheWeb.Router do
  use TcCacheWeb, :router

  scope "/", TcCacheWeb do
    get("/builds", BuildController, :index)
    get("/health", BuildController, :health)
  end
end
