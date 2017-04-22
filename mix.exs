defmodule ExPhoneNumber.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_phone_number,
     version: "0.0.1",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test],
     deps: deps()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:sweet_xml, "~> 0.6.5"},
      {:ex_spec, "~> 2.0", only: :test},
      {:excoveralls, "~> 0.6", only: :test},
      {:credo, "~> 0.7", only: [:dev, :test]}
    ]
  end
end
