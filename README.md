# Multiverse

:fire: Multiple databases for Rails

One of the easiest ways to scale your database is to move large, infrequently-joined tables to a separate database. **ActiveRecord supports multiple databases, but Rails doesn’t provide a way to manage them.** Multiverse changes this.

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

[Rails fixtures](http://guides.rubyonrails.org/testing.html#the-low-down-on-fixtures) work automatically.

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

## History

View the [changelog](https://github.com/ankane/multiverse/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/multiverse/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/multiverse/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features
