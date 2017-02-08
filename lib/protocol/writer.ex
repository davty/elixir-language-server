require Logger

defmodule Exls.Protocol.Writer do

  def write(socket, id, message) do
    body = Poison.encode!(%{id: id, result: message, jsonrpc: "2.0"})
    header = content_length_header(byte_size(body))
    message = header <> body
    Logger.debug message

    :gen_tcp.send(socket, message)
  end

  
  defp content_length_header(length) do
    "Content-Length: #{length}\r\n\r\n"
  end

  defp create(id, result) do
   
     IO.inspect "create"
     IO.inspect encoded
     {:ok, "Content-Length: " <> "#{byte_size(encoded)}" <> "\r\n\r\n" <> encoded <> ""}
  end

end