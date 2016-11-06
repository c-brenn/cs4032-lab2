defmodule Rivet.Listener do
  alias Rivet.Connection

  @moduledoc """
  Accepts connections on a given port.
  Forks a new worker to handle each connection
  """

  @max_connections Application.get_env(:rivet, :max_connections)
  @port Application.get_env(:rivet, :port)

  def init(port \\ @port) do
    IO.puts "Rivet - accepting connections on port: #{port}"
    port
    |> open_socket()
    |> accept_connections()
  end

  defp open_socket(port) do
    {:ok, socket} = :gen_tcp.listen(
      port,
      [:binary, packet: :raw]
    )
    Connection.Registry.register_listener(socket)
    socket
  end

  defp accept_connections(socket) do
    case :gen_tcp.accept(socket) do
      {:ok, client_socket} ->
        Connection.Registry.connection_count()
        |> handle_connection(socket, client_socket)
      _ ->
        System.halt
    end
  end


  defp handle_connection(conn_count, socket, client_socket) when conn_count > @max_connections do
    :gen_tcp.close(client_socket)
    accept_connections(socket)
  end
  defp handle_connection(_, socket, client_socket) do
    {:ok, pid} = Connection.Supervisor.open_connection(client_socket)
    :gen_tcp.controlling_process(client_socket, pid)
    Connection.Registry.register(client_socket, pid)
    accept_connections(socket)
  end
end
