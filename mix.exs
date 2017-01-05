defmodule ExPhoneNumber.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_phone_number,
     version: "0.1.0",
     elixir: "~> 1.3.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test],
     deps: deps,
     description: description,
     package: package]
  end

  def package do
    [files: ["lib", "config", "resources", "README*", "mix.exs"],
     maintainers: ["Jose Miguel Rivero Bruno (@josemrb)"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/socialpaymentsbv/ex_phone_number"}]
  end

  def description do
    """
    A library for parsing, formatting, and validating international phone
    numbers. Based on Google's [libphonenumber](https://github.com/googlei18n/libphonenumber).
    """
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:sweet_xml, "~> 0.6.1"},
      {:ex_spec, "~> 2.0", only: :test},
      {:excoveralls, "~> 0.5.6", only: :test},
      {:credo, "~> 0.4.11", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
