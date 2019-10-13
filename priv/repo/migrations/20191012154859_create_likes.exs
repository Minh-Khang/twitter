defmodule Twitter.Repo.Migrations.CreateLikes do
  use Ecto.Migration

  def change do
    create table(:likes) do
      add :tweet_id, references(:tweets, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:likes, [:tweet_id])
    create index(:likes, [:user_id])
  end
end
