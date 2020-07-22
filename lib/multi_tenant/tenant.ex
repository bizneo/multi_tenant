defmodule MultiTenant.Tenant do
  import Ecto.Query, only: [from: 2]

  @repo Application.get_env(:multi_tenant, :repo)
  @prefix Application.get_env(:multi_tenant, :prefix, "tenant_")
  @migrations_path Application.get_env(:multi_tenant, :migrations_path, "tenant_migrations")

  def build_prefix(tenant), do: @prefix <> tenant

  def tenant_name(@prefix <> name), do: name

  def add_prefix_to_query(queryable, nil), do: queryable

  def add_prefix_to_query(queryable, tenant) do
    queryable |> Ecto.Queryable.to_query() |> Map.put(:prefix, tenant)
  end

  def tenant_exists?(schema), do: tenant_exists?(@repo, schema)

  def tenant_exists?(_repo, nil), do: false

  def tenant_exists?(repo, schema) do
    query = from(schemata in "schemata", where: schemata.schema_name == ^schema)
    repo.exists?(query, prefix: "information_schema")
  end

  @doc ~S"""
  List registered tenant names.
  """
  def list_tenants(), do: list_tenants(@repo)

  def list_tenants(repo) do
    query =
      from(
        schemata in "schemata",
        select: schemata.schema_name,
        where: like(schemata.schema_name, ^"#{@prefix}%"),
        order_by: [asc: schemata.schema_name]
      )

    repo.all(query, prefix: "information_schema")
  end

  def tenant_migrations_path(), do: tenant_migrations_path(@repo)

  def tenant_migrations_path(repo) do
    config = repo.config()

    priv = config[:priv] || "priv/#{repo |> Module.split() |> List.last() |> Macro.underscore()}"

    app = Keyword.fetch!(config, :otp_app)
    Application.app_dir(app, Path.join(priv, @migrations_path))
  end

  def create_tenant(tenant), do: create_tenant(@repo, tenant)
  def create_tenant(repo, tenant), do: repo.query("CREATE SCHEMA \"#{tenant}\"", [])

  def delete_tenant(tenant), do: delete_tenant(@repo, tenant)

  def delete_tenant(rep, tenant),
    do: rep.query!("DROP SCHEMA IF EXISTS \"#{tenant}\" CASCADE", [])
end
