defmodule Exls do

  def main(args) do
    import Supervisor.Spec

    children = [
      supervisor(Task.Supervisor, [[name: Exls.TaskSupervisor]]),
      worker(Task, [Exls.Server, :start, [63213]]),
    ]

    opts = [strategy: :one_for_one, name: Exls.Supervisor]

    Supervisor.start_link(children, opts)

    :timer.sleep(:infinity)
  end
end