# Surgex [![Hex version badge](https://img.shields.io/hexpm/v/surgex.svg?style=flat-square)](https://hexdocs.pm/surgex) [![License badge](https://img.shields.io/hexpm/l/surgex.svg?style=flat-square)](https://github.com/surgeventures/surgex/blob/master/LICENSE.md)

***All Things Elixir @ Surge Ventures Inc, the creators of [Fresha](https://www.fresha.com)***

This is the official entry point and hub for all company-wide Elixir efforts at Surge Ventures.
Here's what you can expect to find in the
[Surgex repository](https://github.com/surgeventures/surgex).

## Surgex bundle

Surgex is a package of cross-project helper modules, each too small or too young to justify
publishing them separately. It currently consists of:

- `Surgex.Changeset`: tools for working with Ecto changesets
- `Surgex.DataPipe`: tools for moving data between PostgreSQL databases and tables
- `Surgex.DateTime`: utilities for creating date times with timezone support
- `Surgex.Parser`: parses, casts and catches errors in the web request input
- `Surgex.Sentry`: extensions to the official Sentry package (deprecated)
- `Surgex.RepoHelpers`: tools for dynamic setup of Ecto repo opts (deprecated)

## Separate packages

Besides the toolbelt bundle inside the Surgex package, we also maintain separate Elixir packages
that contain our bigger and more serious open source efforts. Currently, we own the following repos:

- [Jabbax](https://github.com/surgeventures/jabbax) - JSON API Building Blocks Assembly for Elixir
