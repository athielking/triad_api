defmodule TriadApi.Entities.Card do
  use Ecto.Schema
  import Ecto.Changeset

  @derive{Jason.Encoder, only: [:id, :name, :type, :power_left, :power_top, :power_right, :power_bottom]}
  schema "cards" do
    field :name, :string
    field :type, :string
    field :power_left, :integer
    field :power_top, :integer
    field :power_right, :integer
    field :power_bottom, :integer
    timestamps()
  end

   def changeset(model, params \\ :empty) do
    model
    |> cast(params, [:name, :type, :power_left, :power_top, :power_right, :power_bottom])
  end
end
