# Changelog

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
