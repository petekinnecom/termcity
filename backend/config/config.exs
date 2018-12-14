# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :tc_cache,
  ecto_repos: [TcCache.Repo]

# Configures the endpoint
config :tc_cache, TcCacheWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "zWwKwcIKH7MwEvjEwS8yEtm0H0i8QiW+kFMIUCf5wwqhg/9DcdUcByMeiS9aVSkR",
  render_errors: [view: TcCacheWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: TcCache.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
config :tc_cache, TcCache.Teamcity.Source,
  host: System.get_env("TC_TEAMCITY_HOST"),
  username: System.get_env("TC_TEAMCITY_USERNAME"),
  password: System.get_env("TC_TEAMCITY_PASSWORD")

config :tc_cache, TcCache.Circle.Source,
  token: System.get_env("TC_CIRCLE_TOKEN")

config :tc_cache, TcCache.Authentication,
  github_org: System.get_env("TC_GITHUB_ORG")

import_config "#{Mix.env()}.exs"
