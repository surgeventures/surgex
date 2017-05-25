defmodule Surgex.Mixfile do
  use Mix.Project

  def project do
    [app: :surgex,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package(),
     name: "Surgex",
     description: "All Things Elixir @ Surge Ventures Inc, the creators of Shedul",
     source_url: "https://github.com/surgeventures/surgex",
     homepage_url: "https://github.com/surgeventures/surgex",
     docs: [main: "readme",
            logo: "logo.png",
            extras: ["README.md", "GUIDE.md"]]]
  end

  defp package do
    [maintainers: ["Karol Słuszniak"],
     licenses: ["MIT"],
     links: %{
       "GitHub" => "https://github.com/surgeventures/surgex",
       "Shedul" => "https://www.shedul.com"
     },
     files: ~w(mix.exs lib LICENSE.md README.md GUIDE.md)]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:ex_doc, "~> 0.14", only: :dev, runtime: false}]
  end
end
