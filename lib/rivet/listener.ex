defmodule Rivet.Listener do
  alias Rivet.SocketRegistry

  @moduledoc """
  Accepts connections on a given port.
  Forks a new worker to handle each connection
  """

  def init(port \\ 4000) do
    IO.puts "Rivet - accepting connections on port: #{port}"
    port
    |> open_socket()
    |> accept_connections()
  end

  defp open_socket(port) do
    {:ok, socket} = :gen_tcp.listen(
      port,
      [:binary, packet: :line, active: false]
    )
    SocketRegistry.register_socket(socket)
    socket
  end

  defp accept_connections(socket) do
    case :gen_tcp.accept(socket) do
      {:ok, client_socket} ->
        handle_connection(socket, client_socket)
      _ ->
        System.halt
    end
  end

  defp handle_connection(socket, client_socket) do
    {:ok, pid} = Rivet.Connection.Supervisor.open_connection(client_socket)
    :gen_tcp.controlling_process(client_socket, pid)
    SocketRegistry.register_socket(client_socket, pid)
    accept_connections(socket)
  end
end
