defmodule BackendBattle.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @default_port "4000"

  @impl true
  def start(_type, _args) do
    port = (System.get_env("PORT") || @default_port) |> String.to_integer()

    children = [
      # Starts a worker by calling: BackendBattle.Worker.start_link(arg)
      # {BackendBattle.Worker, arg}
      {Plug.Cowboy, scheme: :http, plug: BackendBattle.AppRouter, options: [port: port]},
      BackendBattle.AppRepo
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BackendBattle.Supervisor]

    Supervisor.start_link(children, opts)
    |> tap(fn _ -> IO.puts("🚀🚀 Server started at http://localhost:#{port}") end)
  end
end
