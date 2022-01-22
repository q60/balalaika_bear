defmodule BalalaikaBear.Mixfile do
  use Mix.Project

  def project do
    [
      app: :balalaika_bear,
      version: "0.2.3",
      elixir: "~> 1.13",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      package: package(),
      description: "VK API wrapper for Elixir",
      name: "BalalaikaBear",
      source_url: "https://github.com/q60/balalaika_bear",
      docs: [logo: "logo.png", extras: ["README.md"]]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :httpoison, :jason]
    ]
  end

  def package do
    [
      maintainers: ["vel"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/q60/balalaika_bear"}
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.3"},
      {:credo, "~> 1.6", only: [:dev, :test]},
      {:mock, "~> 0.3.7", only: :test},
      {:exvcr, "~> 0.13.2", only: :test},
      {:ex_doc, "~> 0.26.0", only: :dev}
    ]
  end
end
