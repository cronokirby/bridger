defmodule Bridger do
  @moduledoc """
  The main application. Starting this connects the bot.
  """
  use Application
  alias Alchemy.Client

  
  def load_commands do
    use Bridger.Commands
  end

  @token Application.fetch_env!(:bridger, :token)

  def start(_type, _args) do
    run = Client.start(@token)
    load_commands()
    run
  end
end
