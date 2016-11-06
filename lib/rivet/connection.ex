defmodule Rivet.Connection do
  alias Rivet.Connection
  use GenServer

  @ip_address Application.get_env(:rivet, :ip_address)
  @port Application.get_env(:rivet, :port)
  @student_number 13327472
  @response_suffix ~s(IP:#{@ip_address}\nPort:#{@port}\nStudentID:#{@student_number}\n)

  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket)
  end

  def init(socket) do
    IO.puts "Connection Opened"
    {:ok, socket}
  end

  def close_connection(pid) do
    GenServer.cast(pid, :close_connection)
  end

  def handle_info({:tcp, _, msg}, socket) do
    handle_tcp(msg, socket)
  end
  def handle_info(_, socket), do: {:noreply, socket}

  defp handle_tcp("HELO" <> _ = msg, socket) do
    response = [msg, @response_suffix]
    :gen_tcp.send(socket, response)
    {:noreply, socket}
  end

  defp handle_tcp("KILL_SERVICE" <> _, socket) do
    Connection.Registry.terminate_open_connections()
    {:noreply, socket}
  end

  defp handle_tcp(_, socket), do: {:noreply, socket}

  def handle_cast(:close_connection, socket) do
    {:stop, {:shutdown, :close_connection}, socket}
  end

  def terminate(:close_connection, socket) do
    :gen_tcp.close(socket)
    Connection.Registry.deregister()
  end
end
