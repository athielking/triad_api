defmodule TriadApi.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :playerIdOne, :integer
      add :playerIdTwo, :integer
      add :started_at, :utc_datetime
      add :ended_at, :utc_datetime

      timestamps()
    end
  end
end
