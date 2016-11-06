defmodule Rivet do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Task, [Rivet.Listener, :init, []], restart: :temporary),
      worker(Rivet.Connection.Registry, []),
      supervisor(Rivet.Connection.Supervisor, [])
    ]

    opts = [strategy: :one_for_one, name: Rivet.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
