defmodule ExPhoneNumber.Mixfile do
  use Mix.Project

  @source_url "https://github.com/socialpaymentsbv/ex_phone_number"
  @version "0.2.1"

  def project do
    [
      app: :ex_phone_number,
      version: @version,
      name: "ExPhoneNumber",
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.travis": :test],
      deps: deps(),
      package: package(),
      description: description(),
      docs: docs()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:sweet_xml, "~> 0.6.5"},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:ex_spec, "~> 2.0", only: :test},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  defp description do
    "A library for parsing, formatting, and validating international phone numbers. " <>
      "Based on Google's libphonenumber."
  end

  defp package do
    [
      files: ["lib", "config", "resources", "LICENSE*", "README*", "mix.exs"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      maintainers: ["ClubCollect (@socialpaymentsbv)", "Jose Miguel Rivero Bruno (@josemrb)"],
      name: :ex_phone_number
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
end
