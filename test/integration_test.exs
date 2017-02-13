defmodule IntegrationTest do
  use ExUnit.Case
  doctest Exls

  setup do
    correct_code = """
defmodule ExampleModule do
  @moduledoc false

  @spec example(integer) :: integer
  def example(n) do
    n + 1
  end
end
""" 
    {:ok, [correct_code: correct_code]}
  end

  test "credo integration", %{correct_code: sample} do 
    result = Exls.Credo.run sample
    assert result == []
  end
end
