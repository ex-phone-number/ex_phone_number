defmodule ExPhoneNumber.Mixfile do
  use Mix.Project

  @source_url "https://github.com/ex-phone-number/ex_phone_number"
  @version "0.4.5"

  def project do
    [
      app: :ex_phone_number,
      version: @version,
      name: "ExPhoneNumber",
      elixir: "~> 1.11",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
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
      {:sweet_xml, "~> 0.7"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:ex_spec, "~> 2.0", only: :test},
      {:req, "~> 0.3.6", only: :dev, optional: true}
    ]
  end

  defp description do
    """
    A library for parsing, formatting, and validating international phone numbers. Based on Google's libphonenumber.
    """
  end

  defp package do
    [
      files: ["lib", "config", "resources", "LICENSE*", "README*", "mix.exs"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      maintainers: [
        "Jose Miguel Rivero Bruno (@josemrb)",
        "Szymon Jeż (@szymon-jez)",
        "Kamil Kowalski (@kamilkowalski)"
      ],
      name: :ex_phone_number
    ]
  end

  defp docs do
    [
      extras: ["README.md", "LICENSE.md", "CHANGELOG.md"],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      homepage_url: @source_url,
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end
end
