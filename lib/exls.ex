defmodule Exls do

  def main(args) do
    args |> parse_args |> process
  end

  def process([]) do
    IO.puts "No arguments given"
  end

  def process(options) do
    {:ok, pid} = Exls.Server.start_link(options[:port])
    Exls.Server.initialize(pid)

    receive_command(pid)
  end

  def receive_command(pid) do
    Exls.Server.command(pid)
  end

  defp parse_args(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [port: :integer]
    )
    options
  end
end
