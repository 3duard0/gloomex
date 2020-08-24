defmodule Gloomex.MixProject do
  use Mix.Project

  def project do
    [
      app: :gloomex,
      description: description(),
      package: package(),
      version: "0.2.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      deps: deps(),
      aliases: aliases(),
      dialyzer: [lt_add_apps: [:ex_unit]],
      preferred_cli_env: [
        quality: :test,
        "quality.ci": :test
      ]
    ]
  end

  def elixirc_paths(:test), do: ["lib", "test/support"]
  def elixirc_paths(_), do: ["lib"]

  def application do
    if Mix.env() == :test do
      [
        extra_applications: [:logger, :runtime_tools]
      ]
    else
      [
        extra_applications: [:logger]
      ]
    end
  end

  defp deps do
    [
      {:murmur, "~> 1.0.1"},

      # Test
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.11", only: :test},
      {:junit_formatter, "~> 3.0", only: :test, override: true},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp aliases do
    [
      quality: [
        "format",
        "credo --strict",
        "coveralls.html -u",
        "dialyzer"
      ],
      "quality.ci": [
        "format --check-formatted",
        "compile --force --warnings-as-errors",
        "credo --strict",
        "coveralls.html -u --raise",
        "dialyzer --halt-exit-status"
      ]
    ]
  end

  defp description do
    "Guava like bloom filter library"
  end

  defp package do
    [
      files: ~w(lib .formatter.exs mix.exs README*),
      licenses: ["Copyright"],
      links: %{"GitHub" => "https://github.com/3duard0/gloomex"}
    ]
  end
end
