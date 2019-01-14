defmodule ExPhoneNumber.Mixfile do
  use Mix.Project

  @version "0.1.2"

  def project do
    [app: :ex_phone_number,
     version: @version,
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [coveralls: :test, "coveralls.travis": :test],
     deps: deps(),
     package: package(),
     description: description(),
     name: "ExPhoneNumber",
     source_url: "https://github.com/socialpaymentsbv/ex_phone_number",
     homepage_url: "https://github.com/socialpaymentsbv/ex_phone_number"]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:sweet_xml, "~> 0.6.5"},
     {:ex_doc, "~> 0.14", only: :dev, runtime: false},
     {:ex_spec, "~> 2.0", only: :test},
     {:excoveralls, "~> 0.6", only: :test},
     {:credo, "~> 0.7", only: [:dev, :test]}]
  end

  defp description do
     "A library for parsing, formatting, and validating international phone numbers. " <>
     "Based on Google's libphonenumber."
  end

  defp package do
    [files: ["lib", "config", "resources", "LICENSE*", "README*", "mix.exs"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/socialpaymentsbv/ex_phone_number"},
     maintainers: ["Jose Miguel Rivero Bruno (@josemrb)"],
     name: :ex_phone_number]
  end
end
