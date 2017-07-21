Application.ensure_all_started(:ex_machina)
Mix.Ecto.ensure_started(Surgex.Repo, [])
Mix.Ecto.ensure_started(Surgex.ForeignRepo, [])

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Surgex.Repo, :manual)
Ecto.Adapters.SQL.Sandbox.mode(Surgex.ForeignRepo, :manual)
