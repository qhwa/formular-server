defmodule Formular.Server.MixProject do
  use Mix.Project

  def project do
    [
      app: :formular_server,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.json": :test,
        "coveralls.html": :test
      ],
      plt_core_path: "_build/#{Mix.env()}",
      releases: [
        formular_server: [
          steps: [:assemble, :tar],
          include_executables_for: [:unix]
        ]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Formular.Server.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 3.0"},
      # Lock Phoenix to v1.7.1 to avoid a bug that causes
      # loosing connection between formular server and
      # other applications.
      {:phoenix, "1.7.1"},
      {:phoenix_view, "~> 2.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.20.0"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8"},
      {:esbuild, "~> 0.2", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.3"},
      {:skooma, "~> 0.2"},
      {:formular, "~> 0.4.1", override: true},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:makeup, "~> 1.1"},
      {:makeup_elixir, "~> 0.16"},
      {:nimble_parsec, "~> 1.3", override: true},
      {:credo, "~> 1.7", runtime: false, only: [:dev, :test]},
      {:healthchex, "~> 0.2"},
      {:excoveralls, "~> 0.14", only: :test},
      {:dialyxir, "~> 1.1", runtime: false, only: [:test, :dev]},
      {:libcluster, "~> 3.3"},
      {:appsignal, "~> 2.2"},
      {:timex, "~> 3.7"},
      {:ueberauth, "~> 0.10", override: true},
      {:ueberauth_github, "~> 0.8"},
      {:ueberauth_keycloak_strategy, "~> 0.3"},
      {:ueberauth_google, "~> 0.10", runtime: true},
      {:canada, "~> 2.0"},
      {:ex_machina, "~> 2.7", only: :test},
      {:tablex, "~> 0.3.1-alpha.4", override: true},
      {:tablex_view, github: "elixir-tablex/tablex_view", branch: "feature/editor"},
      {:tls_certificate_check, "~> 1.20"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": ["esbuild default --minify", "phx.digest"]
    ]
  end
end
