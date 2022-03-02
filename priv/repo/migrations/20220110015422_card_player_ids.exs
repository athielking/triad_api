defmodule TriadApi.Repo.Migrations.CardPlayerIds do
  use Ecto.Migration

  def change do
    drop table(:games)
    create table(:games, primary_key: false) do
      add :id, :uuid, primary_key: true, read_after_writes: true, autogenerate: false, default: fragment("uuid_generate_v4()")
      add :playerIdOne, :uuid, read_after_writes: true, autogenerate: false
      add :playerIdTwo, :uuid, read_after_writes: true, autogenerate: false
      add :started_at, :utc_datetime
      add :ended_at, :utc_datetime

      timestamps()
    end
  end
end
