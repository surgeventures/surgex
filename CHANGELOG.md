# Changelog

## 2.19.0

- Added `Surgex.DataPipe.RepoProxy`

## 2.18.0

- Added `Surgex.Parser.ListParser`

## 2.17.0

- Extended `Surgex.DataPipe.TableSync` with `delete_scope` option
- Fixed `Surgex.DataPipe.TableSync` to properly use Ecto's query params

## 2.16.0

- Extended `Surgex.Parser.FloatParser` with support for integers as input

## 2.15.0

- Extended `Surgex.Parser.FloatParser` with support for floats as input
- Extended `Surgex.Parser.BooleanParser` with support for booleans as input

## 2.14.0

- Extended `Surgex.Parser.FloatParser` with `min` and `max` options

## 2.13.0

- Added `Surgex.Parser.ResourceParser`

## 2.12.1

- Fixed `Surgex.RPC.Client` to support no services in the client
- Refactored `Surgex.RPC` for proper payload - transport separation

## 2.12.0

- Added `Surgex.Parser.SlugParser`
- Added `Surgex.Parser.SlugOrIdParser`

## 2.11.0

- Added support for configuring `Surgex.RPC.HTTPAdapter` via Mix config, powered by `Surgex.Config`
- Added support for passing service name atom to `Surgex.RPC.Client.proto/1`
- Added support for passing arbitrary opts to `Protobuf` via `Surgex.RPC.Client.service/1`

## 2.10.0

- Added `Surgex.RPC`

## 2.9.0

- Added `Surgex.Guide.CodeStyle.typespec_alias_usage/0` rule

## 2.8.0

- Added `Surgex.Config.Patch`

## 2.7.0

- Added `Surgex.Scout` to support setting Scout Agent Key with `{:system, "SCOUT_API_KEY"}`

## 2.6.0

- Added `Surgex.Guide.SoftwareDesign.return_ok_error_usage/0` rule

## 2.5.1

- Fixed `Surgex.DeviseSession` to support `Plug.Conn` with `{:system, "SECRET_KEY_BASE"}`

## 2.5.0

- Added `Surgex.DatabaseCleaner`

## 2.3.0

- Added `Surgex.Guide.CodeStyle.pipe_chain_alignment/0`

## 2.2.1

- Fixed `Surgex.Parser` to return the same error reason multiple times

## 2.2.0

- Added support for raw SQL source in `Surgex.DataPipe.TableSync`

## 2.1.1

- Fixed nil scope bug in `Surgex.Config.get/2`
- Fixed per-repo config parse bug in `Surgex.DataPipe.FollowerSync`

## 2.1.0

- Added support for per-repo config in `Surgex.DataPipe.FollowerSync`

## 2.0.0

- Replaced `Surgex.Config.Session` with `Surgex.DeviseSession`
- Added `Surgex.DataPipe`
- Added `Surgex.Refactor`

## 1.6.0

- Added `Surgex.Config.Session`

## 1.5.2

- Support integer input in `Surgex.Parser.IntegerParser`

## 1.5.1

- Return `invalid` instead of `invalid-cast` in `Surgex.Changeset`

## 1.5.0

- Add `Surgex.Guide.CodeStyle.test_happy_case_placement/0` rule

## 1.4.0

- Keep input nil keys in `Surgex.Parser`

## 1.2.1

- Fix bug in Sentry docs

## 1.2.0

- Added `Surgex.Guide.SoftwareDesign.error_handling/0` rule
- Fixed some other rules

## 1.1.0

- Added `Surgex.PhoneNumber`

## 1.0.0

- Extended `Surgex.Config` to support env var lists
- Changed `Surgex.Config` to take opts via keyword list
- Added `Surgex.Parser` support for nil input
- Extended `Surgex.Parser.IntegerParser` with min and max opts
- Changed `Surgex.Sentry` to run as an OTP app
- Extended `Surgex.Sentry` to take release and environment from Mix
- Completed `Surgex.Guide`
