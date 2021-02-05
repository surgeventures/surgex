Application.ensure_all_started(:ex_machina)

Supervisor.start_link(
  [
    Surgex.Repo,
    Surgex.ForeignRepo
  ],
  strategy: :one_for_one
)

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Surgex.Repo, :manual)
Ecto.Adapters.SQL.Sandbox.mode(Surgex.ForeignRepo, :manual)
