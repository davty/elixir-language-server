require Logger

defmodule Exls.Worker do

  alias Exls.Protocol.Reader
  alias Exls.Protocol.Writer

  def handle_message(client) do
    message = Reader.read(client)
    case message["method"] do
      "initialize" -> Writer.write(client, message["id"], initialize)
      _ -> IO.puts("no freakin idea!" <> message["method"])
    end
    "message"
  end
  
  def initialize do
    %{capabilities: %{textDocumentSync: 1}}
  end
end