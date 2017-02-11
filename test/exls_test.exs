defmodule ExlsTest do
  use ExUnit.Case
  doctest Exls

  #setup do
    #Exls.main([])

    #{:ok, socket} = :gen_tcp.connect('localhost', 63213, [:binary, active: false])
    #{:ok, [socket: socket]}
  #end

  @tag :skip
  test " initialize", %{socket: socket} do
    :ok = :gen_tcp.send(socket, "Hello, world!\n")

    case :gen_tcp.recv(socket, 0) do
      {:ok, response} ->
        assert response == "Hello, world!\n"
        # assert response == "!dlrow ,olleH\n"
      {:error, reason} ->
        flunk "Did notreceiveresponse: #{reason}"
    end
  end

  test "credo integration" do 
    code = """
defmodule ExampleModule do
  def example(n) do
    n + 1
  end
end
""" 
    result = Exls.Credo.run code
    IO.inspect result

    assert 1 == 1
  end
end
