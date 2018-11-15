Application.ensure_all_started(:ex_machina)
Mix.EctoSQL.ensure_started(Surgex.Repo, [])
Mix.EctoSQL.ensure_started(Surgex.ForeignRepo, [])

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Surgex.Repo, :manual)
Ecto.Adapters.SQL.Sandbox.mode(Surgex.ForeignRepo, :manual)
