defmodule Mix.Tasks.MultiTenant.Rollback do
  use Mix.Task

  @shortdoc "Rolls back the repository migrations in tenants"

  @doc false
  def run(args, migrator \\ &Ecto.Migrator.run/4) do
    MultiTenant.migrate(args, migrator, :down)
  end
end
