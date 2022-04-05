defmodule Carpeado.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Carpeado.Consumer
      # Starts a worker by calling: Carpeado.Worker.start_link(arg)
      # {Carpeado.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Carpeado.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
