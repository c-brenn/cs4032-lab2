defmodule Rivet.Connection.Supervisor do
  @name __MODULE__

  def open_connection(socket) do
    Task.Supervisor.start_child(@name, fn ->
      Rivet.Connection.start(socket)
    end)
  end
end
