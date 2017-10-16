defmodule Bridger.Commands do
  @moduledoc """
  This module holds all the commands for the bot.
  """
  use Alchemy.Cogs

  
  Cogs.def ping do
    Cogs.say "pong!"
  end
end