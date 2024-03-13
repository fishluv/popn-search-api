## Run server

```sh
bin/rails s
curl http://localhost:3000/charts?q=cuddle%20core
curl http://localhost:3000/songs?q=cuddle%20core
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
  database: "db/2023121800.with_extras.fts.sqlite3",
)
```

Then do:

```sh
bundle exec annotaterb models
```
