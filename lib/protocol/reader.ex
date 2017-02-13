defmodule Exls.Protocol.Reader do

  def read(socket) do
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