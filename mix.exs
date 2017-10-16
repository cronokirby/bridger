defmodule Bridger.Mixfile do
  use Mix.Project

  def project do
    [
      app: :bridger,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [mod: {Bridger, []}]
  end

  defp deps do
    [
      {:alchemy, "~> 0.6.0", hex: :discord_alchemy},
    ]
  end
end
