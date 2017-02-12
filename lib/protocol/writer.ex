require Logger

defmodule Exls.Protocol.Writer do

  def notification(socket, method, params) do
    body = Poison.encode!(%{method: method, params: params, jsonrpc: "2.0"})
    header = content_length_header(byte_size(body))
    message = header <> body
    :gen_tcp.send(socket, message)
  end

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
end