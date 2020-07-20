# MultiTenant

Database multitenancy for Elixir applications

## Installation

```elixir
def deps do
  [
    {:multi_tenant, github: "bizneo/multi_tenant"}
  ]
end
```

## Configuration

Configure your repo

```elixir
config :multi_tenant, repo: YourApp.Repo
```

## Usage

```elixir
  # Create new tenant
  MultiTenant.create_tenant(tenant)
  # Delete tenant (drop the whole schema)
  MultiTenant.delete_tenant(tenant)
  # Migrate all tenants
  MultiTenant.migrate(args, migrator, direction)
  # Migrage only one tenant
  MultiTenant.migrate_tenant(repo, tenant, direction \\ :up, opts \\ [all: true])
  # List existing tenants
  MultiTenant.list_tenants()
  # Check if a tenant exists
  MultiTenant.tenant_exists?(schema)
  # Get the path configured for tenant migration files
  MultiTenant.tenant_migrations_path()
```

## Tasks

```elixir
  mix multi_tenant.migrate
  mix multi_tenant.rollback
  mix multi_tenant.gen.migration MyNewMigration
```
