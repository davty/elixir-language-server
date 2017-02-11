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
    [applications: [:logger]]
  end

  defp deps do
    [{:poison, "~> 3.0"},
     {:credo, "~> 0.6.1"}]
  end
end
