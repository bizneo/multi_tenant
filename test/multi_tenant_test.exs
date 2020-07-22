defmodule MultiTenantTest do
  use ExUnit.Case

  import Ecto.Query

  alias MultiTenant.Migrator
  alias MultiTenant.Repo

  @tenant "tenant_demo"
  @tenants ["tenant_test_1", "tenant_test_2"]
  @version 20_161_104_124_644

  setup do
    (@tenants ++ [@tenant])
    |> Enum.each(fn tenant ->
      if MultiTenant.tenant_exists?(Repo, tenant) do
        MultiTenant.delete_tenant(Repo, tenant)
      end
    end)

    :ok = Ecto.Adapters.SQL.Sandbox.mode(Repo, :auto)
  end

  test "create/2 must create a new tenant" do
    MultiTenant.create_tenant(Repo, @tenant)

    assert MultiTenant.tenant_exists?(Repo, @tenant)
    assert MultiTenant.list_tenants(Repo) == [@tenant]
  end

  test "delete/2 must drop an existing tenant" do
    MultiTenant.create_tenant(Repo, @tenant)
    assert MultiTenant.tenant_exists?(Repo, @tenant)

    MultiTenant.delete_tenant(Repo, @tenant)
    refute MultiTenant.tenant_exists?(Repo, @tenant)
    assert Enum.empty?(MultiTenant.list_tenants(Repo))
  end

  test "migrate_tenant/2 migrate an existing tenant" do
    MultiTenant.create_tenant(Repo, @tenant)

    {:ok, %{tenant: tenant, versions: versions}} = MultiTenant.migrate_tenant(Repo, @tenant)
    assert versions == [@version]
    assert tenant == @tenant
  end

  test "migrate/2 migrate all existing tenants" do
    Enum.each(@tenants, &MultiTenant.create_tenant(Repo, &1))
    Migrator.run([], &Ecto.Migrator.run/4, :up)

    query = from(users in "users", select: [:username, :first_name])
    # Check that the new migrations with the fields username and first_name have been create
    Enum.each(@tenants, &Enum.empty?(Repo.all(query, prefix: &1)))
  end
end
