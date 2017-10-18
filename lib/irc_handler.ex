defmodule Bridger.IRCHandler do
  @moduledoc """
  The irc connection handler.
  """
  require Logger
  alias Bridger.Sender

  def start_link(host, port, channels) do
    GenServer.start_link(__MODULE__, {host, port, channels})
  end

  def init({host, port, channels}) do
    {:ok, client} = ExIrc.start_client!()
    ExIrc.Client.add_handler(client, self())
    ExIrc.Client.connect!(client, host, port)
    {:ok, %{host: host, port: port, client: client, channels: channels}}
  end 

  def join(pid, channel) do
    GenServer.call(pid, {:join, channel})
  end

  def handle_call({:join, channel}, _from, state) do
    ExIrc.Client.join(state.client, channel)
    {:reply, :ok, state}
  end
  
  def handle_info({:connected, server, port}, state) do
    Logger.debug "IRC connection established with #{server}:#{port}"
    ExIrc.Client.logon(state.client, "", "bridger", "bridger", "bridger")
    {:noreply, state}
  end

  def handle_info(:logged_in, state) do
    Logger.debug "Logged into #{state.host}:#{state.port}"
    for c <- state.channels do
      ExIrc.Client.join(state.client, c)
    end
    {:noreply, state}
  end

  def handle_info({:received, msg, %ExIrc.SenderInfo{nick: nick}, channel}, state) do
    IO.puts("received: #{inspect msg}")
    Sender.send({state.host, state.port, channel}, %{content: msg, username: nick})
    {:noreply, state}
  end

  def handle_info(msg, state) do
    IO.inspect(msg)
    {:noreply, state}
  end

  def terminate(_, state) do
    ExIrc.Client.quit(state.client)
    ExIrc.Client.stop!(state.client)
    :ok
  end
end