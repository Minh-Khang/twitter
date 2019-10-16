defmodule Twitter.Repo.Migrations.CreateOnetimepasses do
  use Ecto.Migration

  def change do
    create table(:onetimepasses) do
      add :secret, :string
      add :otp, :string

      timestamps()
    end

  end
end
