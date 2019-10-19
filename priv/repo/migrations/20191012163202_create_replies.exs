defmodule Twitter.Repo.Migrations.CreateReplies do
  use Ecto.Migration

  def change do
    create table(:replies) do
      add :body, :text
      add :tweet_id, references(:tweets, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:replies, [:tweet_id])
    create index(:replies, [:user_id])
  end
end
