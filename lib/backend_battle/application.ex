defmodule BackendBattle.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @port System.get_env("PORT") || "4000"

  @impl true
  def start(_type, _args) do
    port = String.to_integer(@port)

    children = [
      # Starts a worker by calling: BackendBattle.Worker.start_link(arg)
      # {BackendBattle.Worker, arg}
      {Plug.Cowboy, scheme: :http, plug: BackendBattle.AppRouter, options: [port: port]},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BackendBattle.Supervisor]
    Supervisor.start_link(children, opts)
    |> tap(fn _ -> IO.puts("🚀🚀 Server started at http://localhost:#{@port}") end)
  end
end
