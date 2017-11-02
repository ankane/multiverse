# Multiverse

:fire: Multiple databases for Rails

One of the easiest ways to scale your database is to move large, infrequently-joined tables to a separate database. **ActiveRecord supports multiple databases, but Rails doesn’t provide a way to manage them.** Multiverse changes this.

Works with Rails 5+

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'multiverse'
```

## Getting Started

Generate a new database

```sh
rails generate multiverse:db catalog
```

This generates `CatalogRecord` class for models to inherit from and adds configuration to `config/database.yml`. It also creates a `db/catalog` directory for migrations and `schema.rb` to live.

`rails` and `rake` commands will run for the original database by default. To run commands for the new database, use the `DB` environment variable. For instance:

Create the database

```sh
DB=catalog rake db:create
```

Create a migration

```sh
DB=catalog rails generate migration add_name_to_products
```

Run migrations

```sh
DB=catalog rake db:migrate
```

Rollback

```sh
DB=catalog rake db:rollback
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

## Seeds

Use `db/seeds.rb` for all databases

## Web Servers

### Puma

Add to `config/puma.rb`

```ruby
on_worker_boot do
  CatalogRecord.establish_connection :"catalog_#{Rails.env}"
end
```

### Unicorn

Add to `config/unicorn.rb`

```ruby
before_fork do |server, worker|
  CatalogRecord.connection.disconnect!
end

after_fork do |server, worker|
  CatalogRecord.establish_connection :"catalog_#{Rails.env}"
end
```

## History

View the [changelog](https://github.com/ankane/multiverse/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/multiverse/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/multiverse/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features
