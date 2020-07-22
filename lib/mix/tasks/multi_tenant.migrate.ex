defmodule Mix.Tasks.MultiTenant.Migrate do
  use Mix.Task

  alias MultiTenant.Migrator

  @shortdoc "Runs the repository migrations in tenants"

  @doc false
  def run(args, migrator \\ &Ecto.Migrator.run/4) do
    Migrator.run(args, migrator, :up)
  end
end
