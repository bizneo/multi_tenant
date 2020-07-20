defmodule Mix.Tasks.MultiTenant.Gen.Migration do
  use Mix.Task

  import MultiTenant, only: [tenant_migrations_path: 1]
  import Macro, only: [camelize: 1, underscore: 1]
  import Mix.Ecto
  import Mix.Generator

  @shortdoc "Generates a new tenant migration for the repo"

  @moduledoc """
  Generates a tenant migration.

  The repository must be set under `:ecto_repos` in the
  current app configuration or given via the `-r` option.

  ## Examples

      mix multi_tenant.gen.migration add_posts_table
      mix multi_tenant.gen.migration add_posts_table -r Custom.Repo

  By default, the migration will be generated to the
  "priv/YOUR_REPO/tenant_migrations" directory of the current application
  but it can be configured to be any subdirectory of `priv/YOUR_REPO/*` by
  specifying the `:migrations_path` key under the repository configuration.

  This generator will automatically open the generated file if
  you have `ECTO_EDITOR` set in your environment variable.

  ## Command line options

    * `-r`, `--repo` - the repo to generate migration for

  """

  @switches [change: :string]

  @doc false
  def run(args) do
    no_umbrella!("multi_tenant.gen.migration")
    repo = MultiTenant.repo()

    case OptionParser.parse(args, switches: @switches) do
      {opts, [name], _} ->
        ensure_repo(repo, args)
        path = Path.relative_to(tenant_migrations_path(repo), Mix.Project.app_path())
        file = Path.join(path, "#{timestamp()}_#{underscore(name)}.exs")
        create_directory(path)

        assigns = [
          mod: Module.concat([repo, Migrations, camelize(name)]),
          change: opts[:change]
        ]

        create_file(file, migration_template(assigns))

        if open?(file) and Mix.shell().yes?("Do you want to run this migration?") do
          Mix.Task.run("multi_tenant.migrate", [repo])
        end

      {_, _, _} ->
        Mix.raise(
          "expected multi_tenant.gen.migration to receive the migration file name, " <>
            "got: #{inspect(Enum.join(args, " "))}"
        )
    end
  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: <<?0, ?0 + i>>
  defp pad(i), do: to_string(i)

  embed_template(:migration, """
  defmodule <%= inspect @mod %> do
    use Ecto.Migration

    def change do
  <%= @change %>
    end
  end
  """)
end
