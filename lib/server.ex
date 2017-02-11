require Logger

defmodule Exls.Server do
  @options [:binary, active: false]

  def start(port) do
    Logger.info "Language servers started."
    {:ok, socket} = :gen_tcp.listen(port, @options)
    Logger.debug "Listening on port #{port}."
    loop_acceptor(socket)
  end
  
  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    Logger.debug "Client connected."
    {:ok, pid} = Task.Supervisor.start_child(Exls.TaskSupervisor, fn -> handle_client(client) end)

    :gen_tcp.controlling_process(client, pid)

    loop_acceptor(socket)
  end

  defp handle_client(client) do
    {:ok, agent} = Agent.start_link fn -> -1 end
    Exls.Worker.handle_message(client, agent)
  end

  defp send_message(client, message) do
    :gen_tcp.send(client, message)
  end
end