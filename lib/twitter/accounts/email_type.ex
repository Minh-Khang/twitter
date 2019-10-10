defmodule Twitter.Accounts.EmailType do
  @behaviour Ecto.Type
  def type, do: :string
  def cast(data), do: {:ok, data}
  def load(data), do: {:ok, String.downcase(data)}
  def dump(data), do: {:ok, data}
end
