defmodule Exls do

  @default_port 63212

  def main(args) do

    options = OptionParser.parse(args)

    port = case Enum.at(elem(options, 0), 0) do
      {:port, str} -> String.to_integer(str)
      nil -> @default_port
    end

    Exls.Server.start(port)

    :timer.sleep(:infinity)
  end
end