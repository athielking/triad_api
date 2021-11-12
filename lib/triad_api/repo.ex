defmodule TriadApi.Repo do
  use Ecto.Repo,
    otp_app: :triad_api,
    adapter: Ecto.Adapters.Postgres
end
