defmodule Mix.Tasks.MultiTenant.Migrate do
  use Mix.Task

  @shortdoc "Runs the repository migrations in tenants"

  @doc false
  def run(args, migrator \\ &Ecto.Migrator.run/4) do
    MultiTenant.migrate(args, migrator, :up)
  end
end
