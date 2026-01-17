# Changelog

## [Unreleased]

## [6.0.1]

### Deprecated

- Added compile-time deprecation warnings to `Surgex.Sentry` functions
  - `init/0` - use Elixir 1.9+ runtime configuration instead
  - `scrub_params/1` - use Sentry's built-in scrubbing or implement your own
- Added compile-time deprecation warnings to all `Surgex.RepoHelpers` functions
  - Use Elixir 1.9+ runtime configuration (`config/runtime.exs`) instead
  - See module docs for migration guide

### Changed

- Removed `--warnings-as-errors` from CI to allow deprecation warnings to surface in consumer apps

### Removed

- Removed `Surgex.DataPipe.RepoProxy` module (no external usage found)
- Removed `Surgex.DataPipe.ForeignDataWrapper` module (no external usage found)
- Removed `Surgex.DataPipe.TableSync` module (forked into app-shedul-umbrella, original unused)

## [6.0.0]

### Removed

- Removed `Surgex.Guide` module and submodules (deprecated, use external style guides)
- Removed `Surgex.DatabaseCleaner` module (no external usage found)
- Removed `Surgex.Refactor` module and mix task (no external usage found)
- Removed escript configuration (was only used for refactor command)

## [5.1.1]

- Fixed `Surgex.Parser.DecimalParser` compatibility with Elixir 1.18's gradual type system
- Fixed deprecation warning for map.field notation in `Surgex.DataPipe.ForeignDataWrapper`

## [5.1.0]

- Fixed datetime precision in `Surgex.DateTime.date_and_offset_to_datetime/3` to preserve second
  precision after `Timex.shift/2` calls (which upgrades to microsecond precision)
- Updated CI workflows for Elixir 1.15-1.18 with OTP 26-27

## [5.0.0]

- Fixed an issue with `Surgex.Parser.flat_parse/2` returning values in an unpredictable order when
  parsers were passed as a map. Now, only keyword lists are accepted as parsers to maintain key
  order.

## [4.15.2]

- Using `Logger.warning` instead of deprecated `Logger.warn`

## [4.15.1]

- Fix optional dependency on `Jabbax` and `Plug` by:

    1. defining `Surgex.Parser` only if `Jabbax` is available
    2. defining `Surgex.Sentry` only if `Plug` is available

## [4.15.0]

- Discard unexpected parameters instead of returning 400 Bad Request

## [4.12.0] - 2022-09-05

- New parser (`Surgex.Parser.DefaultParser`) returning default values

## [4.11.0]

- Added ability to return map with `Surgex.Parser.parse_map/2` function

## [4.10.0]

- Extended compatibility with Jabbax to 1.0

## [4.9.0]

- New `:regex` option for `Surgex.Parser.StringParser`, allowing checking input agains given pattern
- New UUID parser (`Surgex.Parser.UuidParser`)
- Add support for :min, :max and :trim option for `Surgex.Parser.EmailParser`

## [4.8.0]

- New `Surgex.DateTime` module with `date_and_offset_to_datetime/3` helper for creating UTC or time-zone date time

## [4.7.0]

- The `Surgex.Parser.RequiredParser` accepts an empty string as valid input

## [4.6.1]

- Parsers can now process any value without throwing exception on unknown value type

## [4.6.0]

- Updated `Surgex.Parser.ResourceArrayParser` to support invalid parameters

## [4.5.0]

- Extended parsers to match empty string values as nil

## [4.4.0]

- Extended parsing of ResourceID ("" -> required)

## [4.3.0]

- Bump minor version

## [4.2.1]

- Extended parsing of boolean ("true" -> true, "false" -> false) and integers ("" -> nil) values

## [4.2.0]

- Added support for translating errors in nested changeset to JSON API responses

## [4.0.0]

- Removed support for AppSignal

## [3.2.8]

- `Surgex.RepoHelpers` sets ecto application_name based on APP_NAME env var

## 3.2.7

- Simplified email regex to fix catastrophic backtracing error when providing longer addresses

## 3.2.6

- Added ssl in `Surgex.RepoHelpers`

## 3.2.5

- Fixed typespec error in `Surgex.Parser.BooleanParser`
- Added `dialyzer --halt-exit-status` to `mix check`

## 3.2.4

- Added typespecs in `Surgex.Parser`
- Deprecated `Surgex.Guide`, `Surgex.RepoHelpers` and `Surgex.Sentry`

## 3.2.3

- Improved `Surgex.DataPipe.ForeignDataWrapper` to alter pg server if it already exists

## 3.2.2

- Fixed error in `Surgex.Appsignal.EctoLogger` for when event is missing stage times

## 3.2.1

- Fixed compilation of `Surgex.Appsignal.EctoLogger`
- Added `:all` value for `:query_stages` option in `Surgex.Appsignal.EctoLogger.handle_event/4`

## 3.2.0

- Added `Surgex.Appsignal.EctoLogger`

## 3.1.0

- Added `Surgex.RepoHelpers.set_pool_size/2` and included it in `set_opts/2`

## 3.0.0

- Extended `Surgex.Parser.IdListParser` with support for list type
- Removed `Surgex.Config`
- Removed `Surgex.DeviseSession`
- Removed `Surgex.PhoneNumber`
- Removed `Surgex.RPC`
- Removed `Surgex.Scout`
- Updated some deps

## 2.24.1

- Added `Surgex.RepoHelpers`

## 2.23.0

- Added `Surgex.DataPipe.PostgresSystemUtils`
- Fixed `Surgex.DataPipe` to support PostgreSQL 10
- Reformatted code with Elixir Formatter
- Deprecated `Surgex.{Config, DeviseSession, PhoneNumber, RPC, Scout}` modules

## 2.22.0

- Extended `Surgex.Parser.StringParser` with `trim`, `min` and `max` options
- Extended `Surgex.Parser.ResourceArrayParser` with `min` and `max` options
- Extended `Surgex.Parser.IncludeParser` with support for multiple includes

## 2.21.0

- Extended `Surgex.DataPipe.RepoProxy` with registry and follower sync

## 2.20.1

- Fixed LSN check in `Surgex.DataPipe.FollowerSync`

## 2.20.0

- Refine error handling in `Surgex.DataPipe.FollowerSync`

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

[Unreleased]: https://github.com/surgeventures/surgex/compare/v6.0.1...HEAD
[6.0.1]: https://github.com/surgeventures/surgex/compare/v6.0.0...v6.0.1
[6.0.0]: https://github.com/surgeventures/surgex/compare/v5.1.1...v6.0.0
[5.1.1]: https://github.com/surgeventures/surgex/compare/v5.1.0...v5.1.1
[5.1.0]: https://github.com/surgeventures/surgex/compare/v5.0.0...v5.1.0
[5.0.0]: https://github.com/surgeventures/surgex/compare/v4.15.2...v5.0.0
[4.15.2]: https://github.com/surgeventures/surgex/compare/v4.15.1...v4.15.2
[4.15.1]: https://github.com/surgeventures/surgex/compare/v4.15.0...v4.15.1
[4.15.0]: https://github.com/surgeventures/surgex/compare/v4.12.0...v4.15.0
[4.12.0]: https://github.com/surgeventures/surgex/compare/v4.11.0...v4.12.0
[4.11.0]: https://github.com/surgeventures/surgex/compare/v4.10.0...v4.11.0
[4.10.0]: https://github.com/surgeventures/surgex/compare/v4.9.0...v4.10.0
[4.9.0]: https://github.com/surgeventures/surgex/compare/v4.8.0...v4.9.0
[4.8.0]: https://github.com/surgeventures/surgex/compare/v4.7.0...v4.8.0
[4.7.0]: https://github.com/surgeventures/surgex/compare/v4.6.1...v4.7.0
[4.6.1]: https://github.com/surgeventures/surgex/compare/v4.6.0...v4.6.1
[4.6.0]: https://github.com/surgeventures/surgex/compare/v4.5.0...v4.6.0
[4.5.0]: https://github.com/surgeventures/surgex/compare/v4.4.0...v4.5.0
[4.4.0]: https://github.com/surgeventures/surgex/compare/v4.3.0...v4.4.0
[4.3.0]: https://github.com/surgeventures/surgex/compare/v4.2.1...v4.3.0
[4.2.1]: https://github.com/surgeventures/surgex/compare/v4.2.0...v4.2.1
[4.2.0]: https://github.com/surgeventures/surgex/compare/v4.0.0...v4.2.0
