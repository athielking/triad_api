defmodule TriadApi.Entities.User do
  use TriadApi.Schema
  import Ecto.Changeset
  import Bcrypt, only: [add_hash: 2]

  schema "users" do
    field :email, :string
    field :password_hash, :string

    # Virtual Fields
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :password_confirmation])
    |> validate_required([:email, :password, :password_confirmation])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}}
        ->
          change(changeset, add_hash(pass, []))
          #put_change(changeset, :password_hash, hash_pw_salt(pass))
      _ ->
          changeset
    end
  end
end
