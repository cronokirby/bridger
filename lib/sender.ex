defmodule Bridger.Sender do
  @moduledoc """
  Acts as a genserver that the different sockets direct their messages to,
  so that this can send it.
  This module also keeps track of, via a dets table, of the different connections it needs
  to keep track of.
  """
  use GenServer
  alias Alchemy.Webhook


  def start_link(filename \\ :irc_links) do
    GenServer.start_link(__MODULE__, {:file, filename}, name: __MODULE__)
  end

  def init({:file, filename}) do
    :dets.open_file(filename, [])
  end

  def terminate(_reason, table) do
    :dets.close(table)
    :normal
  end

  def create_link(%{irc: irc, webhook: webhook} = info) do
    GenServer.call(__MODULE__, {:link_up, info})
  end
  def create_link(_no_info) do
    {:error, "Missing information about the irc channel and webhook"}
  end

  def send(irc, %{content: _, username: _} = msg_info) do
    GenServer.cast(__MODULE__, {:send_message, irc, msg_info})
  end
  
  ### Internal calls ###

  def get_info(table, irc) do
    case :dets.lookup(table, irc) do
      [] ->
        {:error, :no_info}
      [{_, {webhook, image}}] ->
        {:ok, webhook, image}
    end
  end

  def handle_call({:link_up, info}, _from, table) do
    # we don't use .calls to allow for nil info in the image
    # we've already made sure that the webhook key is not empty in the create_link function
    :dets.insert(table, {info.irc, {info[:webhook], info[:image]}})
    {:reply, :ok, table}
  end

  def handle_cast({:send_message, irc, msg_info}, table) do
    IO.inspect(msg_info)
    case get_info(table, irc) do
      {:ok, webhook, image} ->
        options = if image do
          [username: msg_info.username, avatar_url: image]
        else
          [username: msg_info.username]
        end
        Webhook.send(webhook, {:content, msg_info.content}, options)
        {:noreply, table}
    end
  end
end