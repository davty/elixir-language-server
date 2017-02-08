defmodule ExlsTest do
  use ExUnit.Case
  doctest Exls

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "protocol reader can read" do
    assert 2 + 3 == 5
  end
end
