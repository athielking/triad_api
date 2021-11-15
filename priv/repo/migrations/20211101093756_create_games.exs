defmodule TriadApi.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games, primary_key: false) do
      add :id, :uuid, primary_key: true, read_after_writes: true, autogenerate: false, default: fragment("uuid_generate_v4()")
      add :playerIdOne, :integer
      add :playerIdTwo, :integer
      add :started_at, :utc_datetime
      add :ended_at, :utc_datetime

      timestamps()
    end
  end
end
