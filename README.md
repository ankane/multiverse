# Multiverse

:fire: Multiple databases for Rails

**ActiveRecord supports multiple databases, but Rails < 6 doesn’t provide a way to manage them.** Multiverse changes this.

Plus, it’s easy to [upgrade to Rails 6](#upgrading-to-rails-6) when you get there.

Works with Rails 4.2+

[![Build Status](https://travis-ci.org/ankane/multiverse.svg?branch=master)](https://travis-ci.org/ankane/multiverse)

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'multiverse'
```

## Getting Started

In this example, we’ll have a separate database for our e-commerce catalog that we’ll call `catalog`.

The first step is to generate the necessary files.

```sh
rails generate multiverse:db catalog
```

This creates a `CatalogRecord` class for models to inherit from and adds configuration to `config/database.yml`. It also creates a `db/catalog` directory for migrations and `schema.rb` to live.

`rails` and `rake` commands run for the original database by default. To run commands for the new database, use the `DB` environment variable. For instance:

Create the database

```sh
DB=catalog rails db:create
```

Create a migration

```sh
DB=catalog rails generate migration add_name_to_products
```

Run migrations

```sh
DB=catalog rails db:migrate
```

Rollback

```sh
DB=catalog rails db:rollback
```

## Models

Also works for models

```sh
DB=catalog rails generate model Product
```

This generates

```rb
class Product < CatalogRecord
end
```

## Web Servers

*Only necessary in Rails < 5.2*

For web servers that fork, be sure to reconnect after forking (just like you do with `ActiveRecord::Base`)

### Puma

In `config/puma.rb`, add inside the `on_worker_boot` block

```ruby
CatalogRecord.establish_connection :"catalog_#{Rails.env}"
```

### Unicorn

In `config/unicorn.rb`, add inside the `before_fork` block

```ruby
CatalogRecord.connection.disconnect!
```

And inside the `after_fork` block

```ruby
CatalogRecord.establish_connection :"catalog_#{Rails.env}"
```

## Testing

### Fixtures

[Rails fixtures](https://guides.rubyonrails.org/testing.html#the-low-down-on-fixtures) work automatically.

**Note:** Referential integrity is not disabled on additional databases when fixtures are loaded, so you may run into issues if you use foreign keys. Also, you may run into errors with fixtures if the additional databases aren’t the same type as the primary.

### RSpec

After running migrations for additional databases, run:

```sh
DB=catalog rails db:test:prepare
```

### Database Cleaner

Database Cleaner supports multiple connections out of the box.

```ruby
cleaner = DatabaseCleaner[:active_record, {model: CatalogRecord}]
cleaner.strategy = :transaction
cleaner.cleaning do
  # code
end
```

[Read more here](https://github.com/DatabaseCleaner/database_cleaner#how-to-use-with-multiple-orms)

## Limitations

There are a few features that aren’t supported on additional databases.

- Pending migration check
- `schema_cache.yml`

Also note that `ActiveRecord::Migration.maintain_test_schema!` doesn’t affect additional databases.

## Upgrading to Rails 6

Rails 6 provides a way to manage multiple databases :tada:

To upgrade from Multiverse, nest your database configuration in `config/database.yml`:

```yml
# this should be similar to default, but with migrations_paths
catalog_default: &catalog_default
  adapter: ...
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  migrations_paths: db/catalog_migrate

development:
  primary:
    <<: *default
    database: ...
  catalog:
    <<: *catalog_default
    database: ...

test:
  primary:
    <<: *default
    database: ...
  catalog:
    <<: *catalog_default
    database: ...

production:
  primary:
    <<: *default
    database: ...
  catalog:
    <<: *catalog_default
    database: ...
```

Then change `establish_connection` in `app/models/catalog_record.rb` to:

```rb
class CatalogRecord < ActiveRecord::Base
  establish_connection :catalog
end
```

And move:

- `db/catalog/migrate` to `db/catalog_migrate`
- `db/catalog/schema.rb` to `db/catalog_schema.rb` (or `db/catalog/structure.sql` to `db/catalog_structure.sql`).

Then remove `multiverse` from your Gemfile. :tada:

Now you can use the updated commands:

```sh
rails db:migrate          # run all
rails db:migrate:catalog  # runs catalog only
```

Generate migrations with:

```sh
rails generate migration add_name_to_products --database=catalog
```

And models with:

```sh
rails generate model Product --database=catalog --parent=CatalogRecord
```

Happy scaling!

## History

View the [changelog](https://github.com/ankane/multiverse/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/multiverse/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/multiverse/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features
