## 0.2.2

- Raise error when DB specified not in `database.yml`

## 0.2.1

- Added support for `config.paths["db"]`
- Fixed migration generation when DB specified for Rails < 5.0.2
- Fixed Rails API

## 0.2.0

- Added support for Rails 4.2
- Fixed migration generation when DB specified for Rails < 5.0.3
- Less dependencies
- Less patching

## 0.1.2

- Fixed `db:structure:dump` when DB specified
- Fixed `db:schema:cache:dump` when DB specified
- Fixed `db:version` when DB specified
- Fixed `db:seed` when DB specified

## 0.1.1

- Fixed `db:migrate:status` when DB specified
- Better consistency with default behavior when no DB specified

## 0.1.0

- Fixed test conf

## 0.0.3

- Removed debug statement
- Fixed issue with `db:test:prepare`

## 0.0.2

- Better configuration for SQLite
- Fixed issue with `db:schema:load`

## 0.0.1

- First release
