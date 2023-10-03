# TODO: Figure out how to do this via migration.

Rails.application.config.after_initialize do
  if ENV["SKIP_FTS_SETUP"].present?
    log "skipping"
    next
  end

  log "drop existing tables"
  ApplicationRecord.connection.execute("drop table if exists fts_songs")
  ApplicationRecord.connection.execute("drop table if exists fts_charts")

  log "create new tables"
  ApplicationRecord.connection.execute(
    <<~SQL
      create virtual table fts_songs
      using fts5(
        id,
        id_pad,
        folder,
        title_genre,
        artist,
        extra
      )
    SQL
  )
  ApplicationRecord.connection.execute(
    <<~SQL
      create virtual table fts_charts
      using fts5(
        id,
        song_id,
        folder,
        title_genre,
        artist,
        extra,
        difficulty,
        level
      )
    SQL
  )
  # trigram tokenizer isn't shipped with Render's sqlite.

  log "insert song data"
  # Song.first(50).each_with_index do |song, idx|
  Song.find_each.with_index do |song, idx|
    log "song #{idx}/#{Song.count} ..." if idx > 0 && idx % 100 == 0

    values = [
      song.id, # Don't pad this. For joining, not searching.
      pad(song.id),
      pad(norm_folder(song.folder)),
      pad(norm_title_genre(song)),
      pad(song.artist),
      "",
    ]
    ApplicationRecord.connection.execute(
      <<~SQL
        insert into fts_songs (
          id,
          id_pad,
          folder,
          title_genre,
          artist,
          extra
        ) values (
          #{values.map { ApplicationRecord.connection.quote _1 }.join ", "}
        )
      SQL
    )
  end

  log "insert chart data"
  # Song.first(50).each_with_index do |song, idx|
  Song.find_each.with_index do |song, idx|
    log "song #{idx}/#{Song.count} ..." if idx > 0 && idx % 100 == 0

    song.charts.each do |chart|
      values = [
        chart.id, # Don't pad this. For joining, not searching.
        pad(song.id),
        pad(norm_folder(song.folder)),
        pad(norm_title_genre(song)),
        pad(song.artist),
        "",
        pad(norm_diff(chart.difficulty)),
        pad(chart.level),
      ]
      ApplicationRecord.connection.execute(
        <<~SQL
          insert into fts_charts (
            id,
            song_id,
            folder,
            title_genre,
            artist,
            extra,
            difficulty,
            level
          ) values (
            #{values.map { ApplicationRecord.connection.quote _1 }.join ", "}
          )
        SQL
      )
    end
  end

  log "done"
end

def pad(x)
  x.to_s.rjust(3, "_")
end

def norm_title_genre(song)
  [
    song.title,
    song.remywiki_title,
    song.genre,
    song.genre_romantrans,
  ]
    .map(&:downcase)
    .map { _1.gsub(/['"]/, "") } # Quotes are impossible to handle in fts5.
    .uniq
    .join(" ")
end

def norm_folder(folder)
  case folder
  when "27"
    "unilab"
  when "26"
    "kaimei"
  when "25"
    "peace"
  when "24"
    "usaneko"
  when "23"
    "eclale"
  when "22"
    "lapistoria"
  when "21"
    "sunny park"
  when "20"
    "fantasia"
  when "19"
    "tune street"
  when "18"
    "sengoku retsuden"
  when "17"
    "movie"
  when "16"
    "party"
  when "15"
    "adventure"
  when "14"
    "fever"
  when "13"
    "carnival"
  when "12"
    "iroha"
  else
    folder
  end
end

def norm_diff(diff)
  case diff
  when "e"
    "easy"
  when "n"
    "normal"
  when "h"
    "hyper"
  else
    diff
  end
end

def log(s)
  Rails.logger.info "Initializing fts: #{s}"
end
