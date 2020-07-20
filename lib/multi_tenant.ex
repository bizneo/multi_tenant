defmodule MultiTenant do
  @moduledoc """
  Includes basic functions for multi tenancy system.
  """

  alias MultiTenant.Migrator
  alias MultiTenant.Tenant

  def repo(), do: Application.get_env(:multi_tenant, :repo)

  defdelegate build_prefix(tenant), to: Tenant

  defdelegate tenant_name(tenant), to: Tenant

  defdelegate add_prefix_to_query(queryable, tenant), to: Tenant

  defdelegate list_tenants(), to: Tenant
  defdelegate list_tenants(repo), to: Tenant

  defdelegate tenant_migrations_path(), to: Tenant
  defdelegate tenant_migrations_path(repo), to: Tenant

  defdelegate tenant_exists?(schema), to: Tenant
  defdelegate tenant_exists?(repo, schema), to: Tenant

  defdelegate create_tenant(tenant), to: Tenant
  defdelegate create_tenant(repo, tenant), to: Tenant

  defdelegate delete_tenant(tenant), to: Tenant
  defdelegate delete_tenant(repo, tenant), to: Tenant

  defdelegate migrate_tenant(repo, tenant, direction \\ :up, opts \\ [all: true]), to: Migrator
end
