defmodule Surgex.Mixfile do
  use Mix.Project

  def project do
    [app: :surgex,
     version: "2.0.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package(),
     aliases: aliases(),
     test_coverage: [tool: ExCoveralls],
     escript: [main_module: Surgex.Command],
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
    [
      {:credo, "~> 0.8.1", only: [:dev, :test]},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:excoveralls, "~> 0.7", only: :test},
      {:inch_ex, "~> 0.5", only: [:dev, :test]},
    ] ++ optional_deps()
  end

  defp optional_deps do
    [
      {:ecto, "~> 2.1.4"},
      {:ex_phone_number, "~> 0.1.1"},
      {:jabbax, ">= 0.1.0"},
      {:plug, "~> 1.3.2 or ~> 1.4"},
    ] |> Enum.map(&merge_dep_flags(&1, optional: true))
  end

  defp check_alias do
    [
      "deps.get",
      "clean",
      "compile --warnings-as-errors",
      "test",
    ]
  end

  defp merge_dep_flags({pkg, ver}, flags), do: {pkg, ver, flags}
  defp merge_dep_flags({pkg, ver, flg}, flags), do: {pkg, ver, Keyword.merge(flg, flags)}
end
