#!/usr/bin/env bash
set -efux -o pipefail

cat << HEREDOC >> app/models/application_record.rb
ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: "db/2024092500.with_extras.fts.sqlite3",
)
HEREDOC

bundle exec annotaterb models

git restore app/models/application_record.rb
