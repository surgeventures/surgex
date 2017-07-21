Application.ensure_all_started(:ex_machina)
Mix.Ecto.ensure_started(Surgex.Repo, [])

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Surgex.Repo, :manual)
