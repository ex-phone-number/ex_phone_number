defmodule ExPhoneNumber.Mixfile do
  use Mix.Project

  @version "0.2.0"

  def project do
    [
      app: :ex_phone_number,
      version: @version,
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.travis": :test],
      deps: deps(),
      package: package(),
      description: description(),
      name: "ExPhoneNumber",
      source_url: "https://github.com/socialpaymentsbv/ex_phone_number",
      homepage_url: "https://github.com/socialpaymentsbv/ex_phone_number"
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:sweet_xml, "~> 0.6.5"},
      {:ex_doc, "~> 0.18.0", only: :dev, runtime: false},
      {:ex_spec, "~> 2.0", only: :test},
      {:excoveralls, "~> 0.10", only: :test},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false}
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
      links: %{"GitHub" => "https://github.com/socialpaymentsbv/ex_phone_number"},
      maintainers: ["Jose Miguel Rivero Bruno (@josemrb)"],
      name: :ex_phone_number
    ]
  end
end
