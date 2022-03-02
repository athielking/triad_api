defmodule TriadApi.Repo.Migrations.DeckLogic do
  use Ecto.Migration

  def change do

    create table(:decks) do
      add :name, :string
      add :user_id, references(:users, type: :uuid)
      timestamps()
    end

    create table(:deck_cards) do
      add :deck_id, references(:decks)
      add :card_id, references(:cards)
      timestamps()
    end

    create table(:user_cards) do
      add :user_id, references(:users, type: :uuid)
      add :card_id, references(:cards)
      timestamps()
    end

    create table(:game_event) do
      add :event, :string
      add :data, :map
      add :game_id, references(:games, type: :uuid)
      add :user_id, references(:users, type: :uuid)
      timestamps()
    end


  end
end
