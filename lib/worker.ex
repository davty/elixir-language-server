require Logger

defmodule Exls.Worker do
  @moduledoc """
   Worker module
  """

  alias Exls.Protocol.Reader
  alias Exls.Protocol.Writer

  def handle_message(client, agent) do
    message = Reader.read(client)
    Logger.debug "<#{id(agent)}> Got message, method: #{message["method"]}"
    case message["method"] do
      "initialize" -> initialize(client, message, agent)
      "textDocument/didChange" -> text_document_did_change(client, message)
      "textDocument/didOpen" -> text_document_did_change(client, message)
      "textDocument/didSave" -> text_document_did_change(client, message)
      "textDocument/hover" -> hover(client, message)
      _ -> IO.puts("no!")
    end

    unless message["method"] == "shutdown" do
      handle_message(client, agent)
    end
  end

  def id(agent) do
    Agent.get(agent, fn x -> x end)
  end

  def hover(client, request) do
    #message = %{uri: uri, diagnostics: Exls.Credo.run(text)}
    #Writer.notification(client, id(agent), "textDocument/publishDiagnostics", message)

    message = %{
      contents: "what? hmm? :)"
    }
    IO.inspect request
    Writer.write(client, request["id"], message)
  end


  def text_document_did_change(client, notification) do
    uri = notification["params"]["textDocument"]["uri"]
    text = notification["params"]["textDocument"]["text"]
    message = %{uri: uri, diagnostics: Exls.Credo.run(text)}
    Writer.notification(client, "textDocument/publishDiagnostics", message)
  end

  def initialize(client, request, agent) do
    Agent.update(agent, fn _ -> request["id"] end)
    message = %{capabilities: 
      %{textDocumentSync: 1, 
        documentFormattingProvider: true,
        hoverProvider: true,
        completionProvider: true,
        signatureHelpProvider: %{triggerCharacters: ["("]}}
    }
    Writer.write(client, request["id"], message)
  end
end
