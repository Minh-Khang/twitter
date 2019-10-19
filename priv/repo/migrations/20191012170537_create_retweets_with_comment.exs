defmodule Twitter.Repo.Migrations.CreateRetweetsWithComment do
  use Ecto.Migration

  def change do
    create table(:retweets_with_comment) do
      add :body, :text
      add :tweet_id, references(:tweets, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:retweets_with_comment, [:tweet_id])
    create index(:retweets_with_comment, [:user_id])
  end
end
