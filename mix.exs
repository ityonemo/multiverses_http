defmodule MultiversesHttp.MixProject do
  use Mix.Project

  @multiverses_version "0.9.0"
  @plug_version "1.13.0"
  @req_version "0.3.1"

  def project do
    [
      app: :multiverses_http,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: [
        description: "multiverse support for Phoenix.PubSub Library",
        licenses: ["MIT"],
        files: ~w(lib mix.exs README* LICENSE* VERSIONS*),
        links: %{"GitHub" => "https://github.com/ityonemo/multiverses_pubsub"}
      ],
      elixirc_paths: elixirc_paths(Mix.env()),
      docs: [
        main: "Multiverses.Http",
        extras: ["README.md"],
        source_url: "https://github.com/ityonemo/multiverses_http"
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Multiverses.Http.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/_support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # parent library that's being cloned
      {:multiverses, "~> #{@multiverses_version}"},
      {:plug, "~> #{@plug_version}"},
      {:req, "~> #{@req_version}", optional: Mix.env() == :prod},

      # webserver, but don't deploy it to prod.
      {:bandit, "~> 0.5", only: [:dev, :test]},

      # for testing and support
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.0", only: :test},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:dialyxir, "~> 1.2", only: :dev, runtime: false}
    ]
  end
end
