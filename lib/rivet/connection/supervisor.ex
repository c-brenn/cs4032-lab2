defmodule Rivet.Connection.Supervisor do
  use Supervisor
  @name __MODULE__

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def open_connection(socket) do
    Supervisor.start_child(@name, [socket])
  end

  def init(:ok) do
    children = [
      worker(Rivet.Connection, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
