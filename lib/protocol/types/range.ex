defmodule Exls.Protocol.Types.Range do
  alias Exls.Protocol.Types.Position
  
  defstruct start: %Position{}, end: %Position{}

  def point(line, column) do
    position =  %Position{line: line, character: column}
    %{start: position, end: position}
  end
end