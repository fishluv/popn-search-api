## Run server

```sh
bin/rails s
```

## Prepare new db

```sh
bundle exec rake fts:setup
```

## Annotate models

Copy this at the top of application_record.rb:

```rb
ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: "db/2023090500.fts.sqlite3",
)
```

Then do

```sh
bundle exec annotaterb models
```
