defmodule Twitter.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION citext", "DROP EXTENSION citext"
    create table(:users) do
      add :email, :citext, null: false
      add :username, :string, null: false
      add :hash_password, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
