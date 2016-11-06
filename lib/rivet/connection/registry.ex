defmodule Rivet.Connection.Registry do
  alias Rivet.Connection.Registry
  use GenServer

  @name __MODULE__

  defstruct connections: %{}, listener: nil

  # == Public API ==

  def start_link() do
    GenServer.start_link(__MODULE__, %Registry{}, name: @name)
  end

  def connection_count() do
    GenServer.call(@name, :connection_count)
  end

  def register(socket, pid \\ self()) do
    GenServer.cast(@name, {:register, socket, pid})
  end

  def deregister(pid \\ self()) do
    GenServer.cast(@name, {:deregister, pid})
  end

  def register_listener(socket) do
    GenServer.cast(@name, {:register_listener, socket})
  end

  def terminate_open_connections() do
    GenServer.cast(@name, :terminate_open_connections)
  end

  # == GenServer API ==

  def handle_call(:connection_count, _, %Registry{connections: c} = r) do
    conn_count = (c |> Map.keys |> Enum.count) - 1
    {:reply, conn_count, r}
  end

  def handle_cast({:register, socket, pid}, %Registry{connections: c} = r) do
    {:noreply, %{r | connections: Map.put(c, pid, socket)}}
  end

  def handle_cast({:deregister, pid}, %Registry{connections: c} = r) do
    {:noreply, %{r | connections: Map.delete(c, pid)}}
  end

  def handle_cast({:register_listener, socket}, r) do
    {:noreply, %{r | listener: socket}}
  end

  def handle_cast(:terminate_open_connections, r) do
    r.listener |> :gen_tcp.close()
    r.connections
    |> Map.keys
    |> Enum.each(&(GenServer.cast(&1, :close_connection)))
    System.halt
    {:noreply, %Registry{}}
  end
end
