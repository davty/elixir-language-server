defmodule ExlsTest do
  use ExUnit.Case
  doctest Exls

  alias Exls.Protocol.Writer
  alias Exls.Protocol.Reader

  setup do
    Exls.Server.start(63212)
   :ok
  end

  setup do
    opts = [:binary, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', 63212, opts)
    on_exit fn ->
      Writer.call(socket, "shutdown", %{})
    end

    {:ok, socket: socket}
  end
  
  test "should respond to initialize with capabilities", %{socket: socket} do
    Writer.call(socket, "initialize", %{})
    {:ok, response} = Reader.read(socket)
    assert Map.has_key?(response["result"], "capabilities")
  end

  test "should respond with error code for any method that is not implemented", %{socket: socket} do
    Writer.call(socket, "unknown_method", %{})
    {:ok, response} = Reader.read(socket)
    assert response["code"] == -32601
  end
end
