defmodule Twitter.Repo.Migrations.CreateRetweets do
  use Ecto.Migration

  def change do
    create table(:retweets) do
      add :tweet_id, references(:tweets, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:retweets, [:tweet_id])
    create index(:retweets, [:user_id])
  end
end
