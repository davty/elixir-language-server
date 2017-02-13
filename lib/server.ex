require Logger

defmodule Exls.Server do
  @options [:binary, active: false, reuseaddr: true]

  def start(port) do
    import Supervisor.Spec

    children = [
      supervisor(Task.Supervisor, [[name: Exls.TaskSupervisor]]),
      worker(Task, [Exls.Server, :accept, [port]]),
    ]

    opts = [strategy: :one_for_one, name: Exls.Supervisor]

    Supervisor.start_link(children, opts)
  end

  def accept(port) do
    {:ok, socket} = listen(port)
    loop_acceptor(socket)
  end

  def listen(port) do
    {:ok, socket} = :gen_tcp.listen(port, @options)
    {:ok, socket}
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
   # evaluator = IEx.Server.start([], [])
   # Process.put(:evaluator, evaluator)
    Exls.Worker.handle_message(client, agent)
  end
end