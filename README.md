## Prepare new db

```sh
bundle exec rake fts:setup
bash scripts/annotate.sh
```

## Run server

```sh
bin/rails s
curl http://localhost:3000/charts?q=cuddle%20core
curl http://localhost:3000/songs?q=cuddle%20core
```

## Tests

```sh
bundle exec rspec
```
