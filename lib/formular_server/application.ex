defmodule Formular.Server.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Cluster.Supervisor, [topologies(), [name: Formular.Server.ClusterSupervisor]]},
      # Start the Ecto repository
      Formular.Server.Repo,
      # Start the Telemetry supervisor
      Formular.ServerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Formular.Server.PubSub},
      {Formular.Server.Tracker, pubsub_server: Formular.Server.PubSub},
      # Start the Endpoint (http/https)
      Formular.ServerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Formular.Server.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp topologies do
    Application.get_env(:formular_server, :topologies, [])
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Formular.ServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
