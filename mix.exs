defmodule ExPhoneNumber.Mixfile do
  use Mix.Project

  @source_url "https://github.com/socialpaymentsbv/ex_phone_number"
  @version "0.3.0"

  def project do
    [
      app: :ex_phone_number,
      version: @version,
      name: "ExPhoneNumber",
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.travis": :test],
      deps: deps(),
      description: description(),
      dialyzer: dialyzer(),
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  def elixirc_paths(:test), do: ["lib", "test/support"]
  def elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:sweet_xml, "~> 0.7"},
      {:dialyxir, "~> 1.1", only: :dev, runtime: false},
      {:ex_doc, "~> 0.22.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14", only: :test},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    "A library for parsing, formatting, and validating international phone numbers. " <>
      "Based on Google's libphonenumber."
  end

  defp dialyzer do
    [
      flags: [:error_handling, :race_conditions, :underspecs, :unmatched_returns],
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      homepage_url: @source_url
    ]
  end

  defp package do
    [
      files: ["lib", "config", "resources", "LICENSE*", "README*", "mix.exs"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/socialpaymentsbv/ex_phone_number"},
      maintainers: ["ClubCollect (@socialpaymentsbv)", "Jose Miguel Rivero Bruno (@josemrb)"],
      name: :ex_phone_number
    ]
  end
end
