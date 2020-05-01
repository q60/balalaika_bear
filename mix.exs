defmodule BalalaikaBear.Mixfile do
  use Mix.Project

  def project do
    [
      app: :balalaika_bear,
      version: "0.1.3",
      elixir: "~> 1.10.1",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      package: package(),
      description: "VK API wrapper for Elixir",
      name: "BalalaikaBear",
      source_url: "https://github.com/ayrat555/balalaika_bear",
      docs: [logo: "logo.png", extras: ["README.md"]]
    ]
  end

  def application do
    [applications: [:logger, :httpoison]]
  end

  def package do
    [
      maintainers: ["Ayrat Badykov"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/ayrat555/balalaika_bear"}
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.6.2"},
      {:jason, "~> 1.1"},
      {:credo, "~> 1.4.0", only: [:dev, :test]},
      {:mock, "~> 0.3.4", only: :test},
      {:exvcr, "~> 0.11.1", only: :test},
      {:ex_doc, "~> 0.21.3", only: :dev}
    ]
  end
end
