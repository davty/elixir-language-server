require Logger

defmodule Exls.Server do
  @options [:binary, packet: :line, active: false, reuseaddr: true]

  def start(port) do
    {:ok, socket} = :gen_tcp.listen(port, @options)
    Logger.info "Listening on port #{port}."
    loop_acceptor(socket)
  end
  
  defp loop_acceptor(socket) do
    Logger.debug "Accepting new clients."
    IO.inspect socket
    {:ok, client} = :gen_tcp.accept(socket, 20000)
    Logger.debug "client acccepted."
    {:ok, pid} = Task.Supervisor.start_child(Exls.TaskSupervisor, fn -> read_message(client) end)

    :gen_tcp.controlling_process(client, pid)

    loop_acceptor(socket)
  end


  defp read_message(client) do
    case :gen_tcp.recv(client, 0) do
      {:ok, "\r\n"} -> :gen_tcp.close(client)
      {:ok, message} ->
        message |> Exls.Worker.handle_message |> send_message(client)
        read_message(client)
      {:error, _} -> :gen_tcp.close(client)
    end
  end

  defp send_message(client, message) do
    :gen_tcp.send(client, message)
  end
end