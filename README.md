# Surgex [![Hex version badge](https://img.shields.io/hexpm/v/surgex.svg?style=flat-square)](https://hexdocs.pm/surgex) [![License badge](https://img.shields.io/hexpm/l/surgex.svg?style=flat-square)](https://github.com/surgeventures/surgex/blob/master/LICENSE.md) [![Build status badge](https://img.shields.io/codeship/b9a1e790-42d4-0135-8d64-4209f04046aa/master.svg?style=flat-square)](https://app.codeship.com/projects/230448) [![Code quality badge](https://img.shields.io/codeclimate/github/surgeventures/surgex.svg?style=flat-square)](https://codeclimate.com/github/surgeventures/surgex) [![Code coverage badge](https://img.shields.io/codecov/c/github/surgeventures/surgex/master.svg?style=flat-square)](https://codecov.io/gh/surgeventures/surgex/branch/master)

***All Things Elixir @ Surge Ventures Inc, the creators of [Shedul](https://www.shedul.com)***

This is the official entry point and hub for all company-wide Elixir efforts at Surge Ventures.
Here's what you can expect to find in the
[Surgex repository](https://github.com/surgeventures/surgex).

## Elixir knowledge base
a
Official style guide for Elixir and Phoenix projects at Surge Ventures, written in ExDoc format as
a set of functions in the `Surgex.Guide` module ([visit at HexDocs](https://hexdocs.pm/surgex/Surgex.Guide.html)).

## Surgex bundle

Surgex is a package of cross-project helper modules, each too small or too young to justify
publishing them separately. It currently consists of:

- `Surgex.Changeset`: tools for working with Ecto changesets
- `Surgex.DatabaseCleaner`: cleans tables in a database represented by an Ecto repo
- `Surgex.DataPipe`: tools for moving data between PostgreSQL databases and tables
- `Surgex.Parser`: parses, casts and catches errors in the web request input
- `Surgex.Refactor`: tools for making code maintenance and refactors easier
- `Surgex.Sentry`: extensions to the official Sentry package
- `Surgex.RepoHelpers`: tools for dynamic setup of Ecto repo opts

## Separate packages

Besides the toolbelt bundle inside the Surgex package, we also maintain separate Elixir packages
that contain our bigger and more serious open source efforts. Currently, we own the following repos:

- [Jabbax](https://github.com/surgeventures/jabbax) - JSON API Building Blocks Assembly for Elixir
