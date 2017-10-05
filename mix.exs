defmodule Rushie.Mixfile do
  use Mix.Project

  def project do
    [
      app: :rushie,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package(),
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 0.13"},
      {:poison, "~> 3.1"},

      {:bypass, "~> 0.8", only: :test}
    ]
  end

  defp description() do
    "A client library to interact with Rushfiles."
  end

  defp package() do
    [
      maintainers: ["joel@vorce.se"],
      licenses: ["LGPL-3.0"],
      links: %{"GitHub" => "https://github.com/vorce/rushie"}
    ]
  end
end
