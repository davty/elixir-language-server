defmodule Exls.Protocol do


  # should only be sent by clients 
  def initialize(socket, params \\ %{}) do
    notify(socket, :initialize, params)
    Exls.Protocol.Reader.read(socket)
  end

  # should only be sent by clients
  def shutdown(socket) do 
    notify(socket, :shutdown)
  end

  def notify(socket, method, params \\ %{}) do
    body = Poison.encode!(%{method: method, params: params, jsonrpc: "2.0"})
    header = content_length_header(byte_size(body))
    message = header <> body
    :gen_tcp.send(socket, message)
  end

  defp write(socket, id, message) do
    body = Poison.encode!(%{id: id, result: message, jsonrpc: "2.0"})
    header = content_length_header(byte_size(body))
    message = header <> body

    :gen_tcp.send(socket, message)
  end

  defp error(socket, code, message) do
    body = Poison.encode!(%{code: code, message: message, jsonrpc: "2.0"})
    header = content_length_header(byte_size(body))
    message = header <> body

    :gen_tcp.send(socket, message)
  end

  defp content_length_header(length) do
    "Content-Length: #{length}\r\n\r\n"
  end

  defp read(socket) do
    case read_content_length(socket) do
      {:ok, content_length} -> {:ok, read_body(socket, content_length)}
      :closed -> :closed
    end
  end

  defp read_content_length(socket) do
    case read_header(socket) do
      {:ok, header} -> {:ok, header
        |> String.trim
        |> String.split
        |> Enum.at(1)
        |> String.to_integer }
      :closed -> :closed
    end
  end

  defp read_header(socket) do
    read_header(socket, "")
  end

  defp read_body(socket, content_length) do
    case :gen_tcp.recv(socket, content_length) do
      {:ok, body} -> Poison.Parser.parse! body
      {:error, :closed} -> :closed
    end
  end

  defp read_header(socket, buffer) do
    if String.ends_with?(buffer, "\r\n") do
      case :gen_tcp.recv(socket, 2) do
       {:ok, _} -> {:ok, buffer}
       {:error, :closed} -> :closed
      end
    else
      case :gen_tcp.recv(socket, 1) do
        {:ok, message} -> read_header(socket, buffer <> message)
        {:error, :closed} -> :closed
      end
    end
  end
end