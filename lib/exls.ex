defmodule Exls do

  @default_port 63212

  def main(args) do
    import Supervisor.Spec

    options = OptionParser.parse(args)

    port = case Enum.at(elem(options, 0), 0) do
      {:port, str} -> String.to_integer(str)
      nil -> @default_port
    end

    children = [
      supervisor(Task.Supervisor, [[name: Exls.TaskSupervisor]]),
      worker(Task, [Exls.Server, :start, [port]]),
    ]

    opts = [strategy: :one_for_one, name: Exls.Supervisor]

    Supervisor.start_link(children, opts)

    :timer.sleep(:infinity)
  end
end