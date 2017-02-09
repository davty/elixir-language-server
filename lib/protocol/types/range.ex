defmodule Exls.Protocol.Types.Range do
  alias Exls.Protocol.Types.Position
  
  defstruct start: %Position{}, end: %Position{}
end