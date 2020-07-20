defmodule MultiTenant.Migrator do
  import Mix.Ecto

  require Logger

  alias MultiTenant.Tenant

  @repo Application.get_env(:multi_tenant, :repo)

  @doc ~S"""
  This funtion is usually called from a migration task. It migrates all tenants from pending migration
  files definded in priv/repo/tenant_migrations

  Example:
    Migrator.run(args, &Ecto.Migrator.run/4, :up)
  """
  def run(args, migrator, direction) do
    Code.compiler_options(ignore_module_conflict: true)

    {opts, _, _} =
      OptionParser.parse(args,
        switches: [
          all: :boolean,
          step: :integer,
          to: :integer,
          quiet: :boolean,
          prefix: :string,
          pool_size: :integer,
          log_sql: :boolean,
          strict_version_order: :boolean
        ],
        aliases: [n: :step]
      )

    opts =
      if opts[:to] || opts[:step] || opts[:all],
        do: opts,
        else: Keyword.put(opts, :all, true)

    opts =
      if opts[:quiet],
        do: Keyword.merge(opts, log: false, log_sql: false),
        else: opts

    ensure_repo(@repo, args)

    {:ok, _migrated, _apps} =
      Ecto.Migrator.with_repo(@repo, fn repo ->
        migrate_repo_tenants(repo, migrator, direction, opts)
      end)

    Code.compiler_options(ignore_module_conflict: false)
  end

  @doc ~S"""
  Apply migrations to a tenant. A direction can be given (:up or :down).
  Default value is :up. A strategy can be given as an option, and defaults to `:all`.

  ## Options (fourth parameter)

    - `:all`: runs all available if `true`.
    - `:step`: runs the specific number of migrations.
    - `:to`: runs all until the supplied version is reached.
    - `:log`: the level to use for logging. Defaults to `:info`.

  """
  def migrate_tenant(repo, tenant, direction \\ :up, opts \\ [all: true]) do
    with result <- migrate_and_return_status(repo, tenant, direction, opts),
         {:error, tenant_name, error_msg} <- result do
      Logger.error("Error while migrating tenant '#{tenant_name}'. Error was:\n  #{error_msg}")
      {:error, {tenant_name, error_msg}}
    else
      result -> result
    end
  end

  defp migrate_repo_tenants(repo, migrator, direction, opts) do
    Enum.map(Tenant.list_tenants(), fn tenant ->
      opts = Keyword.put(opts, :prefix, tenant)
      path = Tenant.tenant_migrations_path(repo)

      # migrator is just a reference to &Ecto.Migrator.run/4
      migrator.(repo, path, direction, opts)
    end)
  end

  defp migrate_and_return_status(repo, tenant, direction, opts) do
    {status, versions} =
      handle_database_exceptions(fn ->
        opts_with_prefix = Keyword.put(opts, :prefix, tenant)

        Ecto.Migrator.run(
          repo,
          Tenant.tenant_migrations_path(repo),
          direction,
          opts_with_prefix
        )
      end)

    {status, %{tenant: tenant, versions: versions}}
  end

  defp handle_database_exceptions(fun) do
    {:ok, fun.()}
  rescue
    e in Postgrex.Error -> {:error, Postgrex.Error.message(e)}
  end
end
