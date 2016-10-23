defmodule Rivet.SocketRegistry do
  @name __MODULE__

  def start_link() do
    Agent.start_link(fn -> Map.new() end, name: @name)
  end

  def register_socket(socket, pid \\ self()) do
    Agent.update(@name, &Map.put(&1, pid, socket))
  end

  def deregister_socket(pid) do
    Agent.update(@name, &Map.delete(&1, pid))
  end
end
