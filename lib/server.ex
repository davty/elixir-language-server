defmodule Exls.Server do

  use GenServer

  @initial_state %{socket: nil, port: nil, options: nil}

  def start_link(port) do
    GenServer.start_link(__MODULE__, %{@initial_state | port: port})
  end

  def init(state) do
    opts = [:binary, active: false]
    case :gen_tcp.connect('127.0.0.1', state[:port], opts) do
      {:ok, socket} -> {:ok, %{state | socket: socket}}
    end
  end

  def command(pid, cmd) do
    GenServer.call(pid, {:command, cmd})
  end

   def command(pid) do
    GenServer.call(pid, :command, :infinity)
  end

  def initialize(pid) do
    GenServer.call(pid, :initialize)
  end

  defp content_length(socket) do
    
    {:ok, msg} = :gen_tcp.recv(socket, 0)
    msg
      |> String.trim
      |> String.split
      |> Enum.at(1)
      |> String.to_integer
  end

  def handle_call(:initialize, _from, %{socket: socket} = state) do
    {:ok, msg} = :gen_tcp.recv(socket, content_length(socket))
    options = Poison.decode!(msg)
    serverCapabilities = %{capabilities: [%{textDocumentSync: true}]}
    {:ok, a} = create(options["id"], serverCapabilities)
    :gen_tcp.send(socket, a)
    {:reply, msg, %{state | options: options}}
  end

  defp create(id, result) do
    encoded = Poison.encode!(%{id: id, result: result})
    IO.inspect "create"
    IO.inspect encoded
    {:ok, "Content-Length: " <> "#{byte_size(encoded)}" <> "\r\n" <> encoded <> "\r\n\r\n"}
  end

  def handle_call(:command, _from, %{socket: socket} = state) do
   {:ok, msg} = :gen_tcp.recv(socket, 0)
   IO.inspect "command?"
   IO.inspect msg
   {:ok, msg}
  end
end