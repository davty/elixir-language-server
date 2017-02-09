require Logger

defmodule Exls.Worker do

  alias Exls.Protocol.Reader
  alias Exls.Protocol.Writer
  alias Exls.Protocol.Types
  alias Exls.Protocol.Types.Range

  def handle_message(client, agent) do
    message = Reader.read(client)
    Logger.debug "<#{id(agent)}> Got message, method: #{message["method"]}"
    case message["method"] do 
      "initialize" -> initialize(client, message, agent)
     # "textDocument/didChange" -> _ #text_document_did_change(client, message, agent)
      "textDocument/didOpen" -> text_document_did_change(client, message, agent)
      _ -> IO.puts("no freakinsssssidsess!")
    end
    handle_message(client, agent)
  end

  def id(agent) do
    Agent.get(agent, fn x -> x end)
  end
  
  def text_document_did_change(client, notification, agent) do
    Writer.notification(client, id(agent), "window/showMessage", %{type: 3, message: "hej!!"})
    #Writer.notification(client, id(agent), "window/logMessage", %{type: 1, message: "hej!!"})
    
    uri = notification["params"]["textDocument"]["uri"]
    message = %{uri: uri, diagnostics: [%{message: "hmmss??", range: %Range{}}]}
    Writer.notification(client, id(agent), "textDocument/publishDiagnostics", message)
  end

  def initialize(client, request, agent) do
    Agent.update(agent, fn x -> request["id"] end)
    message = %{capabilities: %{textDocumentSync: 1, documentFormattingProvider: true}}
    Writer.write(client, request["id"], message)
  end
end