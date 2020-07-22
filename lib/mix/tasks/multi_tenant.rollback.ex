defmodule Mix.Tasks.MultiTenant.Rollback do
  use Mix.Task

  alias MultiTenant.Migrator

  @shortdoc "Rolls back the repository migrations in tenants"

  @doc false
  def run(args, migrator \\ &Ecto.Migrator.run/4) do
    Migrator.run(args, migrator, :down)
  end
end
