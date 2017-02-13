defmodule ExlsTest do
  use ExUnit.Case
  doctest Exls

  alias Exls.Protocol

  setup_all do
    Exls.Server.start(63212)

    opts = [:binary, active: false]
    {:ok, server} = :gen_tcp.connect('localhost', 63212, opts)

    {:ok, server: server}
  end
  
  test "should respond to initialize with capabilities", %{server: server} do
    {:ok, response} = Protocol.initialize(server)

    assert Map.has_key?(response["result"], "capabilities")
  end

  test "should respond with error code for any method that is not implemented", %{server: server} do
    Protocol.notify(server, :unknown_method)
    {:ok, response} = Exls.Protocol.Reader.read(server)
    assert response["code"] == -32601
  end

  test "linting should report errors on opening a file with linting errors", %{server: server} do 
    Protocol.initialize(server)

    send_text_document_did_open(server, "test/example_bad_code.ex")
    {:ok, response} = Exls.Protocol.Reader.read(server)
    assert length(response["params"]["diagnostics"]) > 0
  end

  test "linting should report zero errors on opening a file with no linting errors", %{server: server} do 
    Protocol.initialize(server)

    send_text_document_did_open(server, "test/example_good_code.ex")
    {:ok, response} = Exls.Protocol.Reader.read(server)
    
    assert response["params"]["diagnostics"] == []
  end

  defp send_text_document_did_open(server, file) do
    Protocol.notify(server, :"textDocument/didOpen", %{textDocument: %{languageId: "elixir", version: 1, uri: "file:///#{file}", text: File.read!(file) }})
  end
end