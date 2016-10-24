defmodule Rivet.SocketRegistry do
  @name __MODULE__

  def start_link() do
    Agent.start_link(fn -> Map.new() end, name: @name)
  end

  def open_connections() do
    Agent.get(@name, fn state ->
      state
      |> Map.keys
      |> Enum.count
    end)
  end

  def register_socket(socket, pid \\ self()) do
    Agent.update(@name, &Map.put(&1, pid, socket))
  end

  def deregister_socket(pid) do
    Agent.update(@name, &Map.delete(&1, pid))
  end

  def terminate_all_connections() do
    Agent.get_and_update(@name, fn connections ->
      connections
      |> Map.values()
      |> Enum.each(&:gen_tcp.close/1)
      {:ok, %{}}
    end)
    System.halt
  end
end
