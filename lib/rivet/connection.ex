defmodule Rivet.Connection do
  alias Rivet.{
    Connection,
    SocketRegistry
  }

  defstruct [:socket, :body, :status]

  @ip_address Application.get_env(:rivet, :ip_address)
  @port Application.get_env(:rivet, :port)
  @student_number 13327472
  @response_suffix ~s(IP:#{@ip_address}\nPort:#{@port}\nStudentId:#{@student_number}\n)

  def start(socket) do
    IO.puts "Connection Opened"
    %Connection{socket: socket, status: :ok}
    |> serve()
  end

  defp serve(%Connection{status: :ok} = conn) do
    conn
    |> read_line()
    |> determine_response()
    |> respond()
    |> serve()
  end
  defp serve(_) do
    SocketRegistry.deregister_socket(self())
    IO.puts "Connection Closed"
  end

  defp read_line(conn) do
    {status, data} = :gen_tcp.recv(conn.socket, 0)
    %{conn | body: data, status: status}
  end

  defp determine_response(%Connection{body: "KILL_SERVICE" <> _} = conn) do
    %{conn | status: :terminate}
  end
  defp determine_response(conn), do: conn

  defp respond(%Connection{status: :ok} = conn) do
    response = conn.body <> @response_suffix
    :gen_tcp.send(conn.socket, response)
    conn
  end
  defp respond(%Connection{status: :terminate} = conn) do
    SocketRegistry.terminate_all_connections()
    conn
  end
  defp respond(conn), do: conn
end
