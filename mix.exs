defmodule Surgex.Mixfile do
  use Mix.Project

  def project do
    [app: :surgex,
     version: "1.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package(),
     aliases: aliases(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [
       check: :test,
       coveralls: :test,
       "coveralls.detail": :test,
       "coveralls.html": :test],
     name: "Surgex",
     description: "All Things Elixir @ Surge Ventures Inc, the creators of Shedul",
     source_url: "https://github.com/surgeventures/surgex",
     homepage_url: "https://github.com/surgeventures/surgex",
     docs: [main: "readme",
            logo: "logo.png",
            extras: ["README.md"]]]
  end

  defp package do
    [maintainers: ["Karol Słuszniak"],
     licenses: ["MIT"],
     links: %{
       "GitHub" => "https://github.com/surgeventures/surgex",
       "Shedul" => "https://www.shedul.com"
     },
     files: ~w(mix.exs lib LICENSE.md README.md)]
  end

  def application do
    [mod: {Surgex.Application, []},
     extra_applications: [:logger]]
  end

  defp aliases do
    [
      "check": check_alias(),
    ]
  end

  defp deps do
    [{:credo, "~> 0.8.1", only: [:dev, :test]},
     {:ecto, "~> 2.1.4", optional: true},
     {:ex_doc, "~> 0.14", only: :dev, runtime: false},
     {:ex_phone_number, "~> 0.1.1", optional: true},
     {:excoveralls, "~> 0.7", only: :test},
     {:inch_ex, "~> 0.5", only: [:dev, :test]},
     {:jabbax, ">= 0.1.0", optional: true}]
  end

  defp check_alias do
    [
      "deps.get",
      "clean",
      "compile --warnings-as-errors",
      "test",
    ]
  end
end
