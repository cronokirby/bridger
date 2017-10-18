defmodule Bridger.Commands do
  @moduledoc """
  This module holds all the commands for the bot.
  """
  use Alchemy.Cogs
  alias Alchemy.Webhook
  alias Bridger.{Sender, IRCHandler}

  
  Cogs.def ping do
    Cogs.say "pong!"
  end

  Cogs.def linkup(server, port, channel, webhook_name) do
    {:ok, guild_id} = Cogs.guild_id()
    with {:ok, webhooks} <- Webhook.in_guild(guild_id),
         w when w != nil <- Enum.find(webhooks, & &1.name == webhook_name),
         {p, _} <- Integer.parse(port),
         :ok <- Sender.create_link(%{irc: {server, p, channel}, webhook: w}),
         {:ok, _} <- IRCHandler.start_link(server, p, [channel])
    do
      Cogs.say("Link created between #{server}:#{port}/#{channel}, and #{webhook_name}")
    else
      nil ->
        Cogs.say("`#{webhook_name} doesn't seem to be a valid webhook in this guild`")
      :error ->
        Cogs.say("Please enter a valid port number")
      {:error, _} ->
        Cogs.say("There was an error establishing the IRC connection")
    end
  end
end