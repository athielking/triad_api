defmodule TriadApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      TriadApi.Repo,
      # Start the Telemetry supervisor
      TriadApiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: TriadApi.PubSub},
      # Start Presence
      TriadApiWeb.Presence,
      # Start the Endpoint (http/https)
      TriadApiWeb.Endpoint,
      # Start a worker by calling: TriadApi.Worker.start_link(arg)
      # {TriadApi.Worker, arg}

      #Start the dynamic game server supervisor
      {DynamicSupervisor, name: TriadApi.GameSupervisor, strategy: :one_for_one},
      {Registry, keys: :unique, name: TriadApi.GameRegistry}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TriadApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TriadApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
