## 0.2.2 (2019-10-27)

- Raise error when DB specified not in `database.yml`

## 0.2.1 (2018-08-23)

- Added support for `config.paths["db"]`
- Fixed migration generation when DB specified for Rails < 5.0.2
- Fixed Rails API

## 0.2.0 (2018-02-19)

- Added support for Rails 4.2
- Fixed migration generation when DB specified for Rails < 5.0.3
- Less dependencies
- Less patching

## 0.1.2 (2018-01-19)

- Fixed `db:structure:dump` when DB specified
- Fixed `db:schema:cache:dump` when DB specified
- Fixed `db:version` when DB specified
- Fixed `db:seed` when DB specified

## 0.1.1 (2018-01-12)

- Fixed `db:migrate:status` when DB specified
- Better consistency with default behavior when no DB specified

## 0.1.0 (2017-11-12)

- Fixed test conf

## 0.0.3 (2017-11-03)

- Removed debug statement
- Fixed issue with `db:test:prepare`

## 0.0.2 (2017-11-02)

- Better configuration for SQLite
- Fixed issue with `db:schema:load`

## 0.0.1 (2017-11-01)

- First release
