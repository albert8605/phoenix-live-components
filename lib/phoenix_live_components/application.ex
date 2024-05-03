defmodule PhoenixLiveComponents.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhoenixLiveComponentsWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:phoenix_live_components, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PhoenixLiveComponents.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PhoenixLiveComponents.Finch},
      # Start a worker by calling: PhoenixLiveComponents.Worker.start_link(arg)
      # {PhoenixLiveComponents.Worker, arg},
      # Start to serve requests, typically the last entry
      PhoenixLiveComponentsWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhoenixLiveComponents.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhoenixLiveComponentsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
