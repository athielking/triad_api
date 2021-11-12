defmodule TriadApi.Repo.Migrations.CreateCards do
  use Ecto.Migration

  def change do
    create table(:cards) do
      add :name, :string
      add :type, :string
      add :power_left, :integer
      add :power_top, :integer
      add :power_right, :integer
      add :power_bottom, :integer
      timestamps()
    end
  end
end
