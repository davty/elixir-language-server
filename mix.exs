defmodule Exls.Mixfile do
  use Mix.Project

  def project do
    [app: :exls,
     version: "0.1.0",
     elixir: "~> 1.3",
     escript: [main_module: Exls],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :iex],
     env: [
       inspect: [pretty: true]
     ]]
  end

  defp deps do
    [{:poison, "~> 3.0"},
     {:credo, "~> 0.6.1"},
     {:mix_test_watch, "~> 0.3", only: :dev, runtime: false}
     ]
  end
end
