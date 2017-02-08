defmodule Exls.Protocol.Reader do

  def read(socket) do
    content_length = read_content_length(socket)
    read_body(socket, content_length)
  end

  defp read_content_length(socket) do
    read_header(socket)
      |> String.trim
      |> String.split
      |> Enum.at(1)
      |> String.to_integer
  end

  defp read_header(socket) do
    read_header(socket, "")
  end

  defp read_body(socket, content_length) do
    {:ok, body} = :gen_tcp.recv(socket, content_length)
    Poison.Parser.parse! body
  end

  defp read_header(socket, buffer) do
    if String.ends_with?(buffer, "\r\n") do
      :gen_tcp.recv(socket, 2)
      buffer
    else
      {:ok, message} = :gen_tcp.recv(socket, 1)
      read_header(socket, buffer <> message)
    end
  end
end