defmodule Surgex.Mixfile do
  use Mix.Project

  def project do
    [app: :surgex,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()] ++ ex_doc_project()
  end

  def ex_doc_project do
    [name: "Surgex",
     source_url: "https://github.com/surgeventures/surgex",
     homepage_url: "https://github.com/surgeventures/surgex",
     docs: [main: "README",
            extras: ["README.md"]]]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:ex_doc, "~> 0.14", only: :dev, runtime: false}]
  end
end
