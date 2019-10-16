defmodule Twitter.Accounts.Onetimepass do
  use Ecto.Schema
  import Ecto.Changeset

  schema "onetimepasses" do
    field :otp, :string
    field :secret, :string

    timestamps()
  end

  @doc false
  def changeset(onetimepass, attrs) do
    onetimepass
    |> cast(attrs, [:secret, :otp])
    |> validate_required([:secret, :otp])
  end
end
