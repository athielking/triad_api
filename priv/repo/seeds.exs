# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TriadApi.Repo.insert!(%TriadApi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
File.stream!("priv/repo/cards.csv") |>
  Stream.map( fn str -> String.split(str, ",") end ) |>
  Stream.map( fn arr -> %{
    name: Enum.at(arr, 0),
    type: "unit",
    power_top: String.to_integer(Enum.at(arr, 1)),
    power_right: String.to_integer(Enum.at(arr, 2)),
    power_bottom: String.to_integer(Enum.at(arr, 3)),
    power_left: String.to_integer(Enum.at(arr, 4))
  } end) |>
  Enum.each(fn card -> TriadApi.Cards.create_card!(card) end)
