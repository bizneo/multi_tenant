# use Mix.Config

# # Configure multi_tenant

use Mix.Config

# Configure your database
config :multi_tenant, ecto_repos: [MultiTenant.Repo]

config :multi_tenant, MultiTenant.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "multi_tenant_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  port: 5432,
  ownership_timeout: :infinity,
  timeout: :infinity

config :multi_tenant, repo: MultiTenant.Repo

config :logger, level: :warn
