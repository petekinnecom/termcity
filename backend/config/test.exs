use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :tc_cache, TcCacheWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :tc_cache, TcCache.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: "root",
  password: "",
  database: "tc_cache_test",
  hostname: System.get_env("DB_HOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  ownership_timeout: 999_999

config :tc_cache, TcCache.Sync.Scheduler, enabled: false

config :tc_cache, TcCache.Source,
  host: "https://example.com",
  username: "username-val",
  password: "password-val",
  github_org: "myOrg"
