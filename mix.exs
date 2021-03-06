defmodule Rushie.Mixfile do
  use Mix.Project

  def project do
    [
      app: :rushie,
      version: "0.1.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.0"},
      {:jason, "~> 1.1"},
      {:credo, "~> 0.10", only: :dev},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:bypass, "~> 0.8", only: :test},
      {:excoveralls, "~> 0.7", only: :test}
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
