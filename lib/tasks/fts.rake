namespace :fts do
  desc "Drop existing virtual tables"
  task drop: [:environment] do
    log "dropping existing tables"
    ApplicationRecord.connection.execute("drop table if exists fts_songs")
    ApplicationRecord.connection.execute("drop table if exists fts_charts")
    log "done"
  end

  desc "Initialize virtual tables"
  task init: [:drop] do
    log "initializing new tables"
    ApplicationRecord.connection.execute(
      <<~SQL
        create virtual table fts_songs
        using fts5(
          id,
          id_pad,
          folder,
          title_genre,
          artist,
          extra,
          diffs_levels,
          chara1_disp_name,
          charas_romantrans
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
          level,
          chara1_disp_name,
          charas_romantrans
        )
      SQL
    )
    # trigram tokenizer isn't shipped with Render's sqlite.
  end

  desc "Setup virtual tables"
  task setup: [:init] do
    log "inserting song and chart data"
    # Song.first(5).each_with_index do |song, idx|
    Song.find_each.with_index do |song, idx|
      log "song #{idx}/#{Song.count} ..." if idx > 0 && idx % 100 == 0

      values = [
        song.id, # Don't pad this. For joining, not searching.
        pad(song.id),
        pad(norm_folder(song.folder)),
        pad(norm_title_genre(song)),
        pad(norm_artist(song.artist)),
        song.labels.join(" "),
        song.charts.map { "#{norm_diff(_1.difficulty)} #{_1.level}" }.join(" "),
        song.character1&.disp_name, # Character _should_ always be present but just in case...
        pad(norm_charas(song.remywiki_chara)),
      ]
      ApplicationRecord.connection.execute(
        <<~SQL
          insert into fts_songs (
            id,
            id_pad,
            folder,
            title_genre,
            artist,
            extra,
            diffs_levels,
            chara1_disp_name,
            charas_romantrans
          ) values (
            #{values.map { ApplicationRecord.connection.quote _1 }.join ", "}
          )
        SQL
      )

      valueses = song.charts.map do |chart|
        csv = [
          chart.id, # Don't pad this. For joining, not searching.
          pad(song.id),
          pad(norm_folder(song.folder)),
          pad(norm_title_genre(song)),
          pad(norm_artist(song.artist)),
          (song.labels + chart.labels).join(" "),
          pad(norm_diff(chart.difficulty)),
          pad(chart.level),
          pad(song.character1&.disp_name), # Character _should_ always be present but just in case...
          pad(norm_charas(song.remywiki_chara)),
        ]
          .map { ApplicationRecord.connection.quote _1 }
          .join(", ")
        "(#{csv})"
      end.join(",")
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
            level,
            chara1_disp_name,
            charas_romantrans
          ) values #{valueses}
        SQL
      )
    rescue
      puts song
      raise
    end

    log "done"
  end
end

def pad(x)
  x.to_s.rjust(3, "_")
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

def norm_title_genre(song)
  [
    song.title,
    song.remywiki_title,
    song.genre,
    song.genre_romantrans,
  ]
    .map(&:downcase)
    .uniq
    .join(" ")
end

ARTIST_ALIASES_AND_RELATED_NAMES = {
  [/日向美ビタースイーツ/] => %w[hinabitter hinabita],
  [/ここなつ/] => %w[hinabitter hinabita coconatsu],
  [
    /Power Of Nature/,
    /Mystic Moon/,
    /Zutt/,
  ] => %w[pon],
  [/GeMiNioИ/] => %w[pon akhuta],
  [
    /^colors$/,
    /Cuvelia/,
    /Risk Junk/,
    /South Carolina Duzzle/,
  ] => ["dj taka"],
  [/iconoclasm/] => ["dj taka", "wac"],
  [/HuΣeR/] => ["humer"],
}.freeze

def norm_artist(artist)
  all_names = [artist]
  ARTIST_ALIASES_AND_RELATED_NAMES.each do |aliases, related_names|
    all_names += related_names if aliases.any? { _1.match?(artist) }
  end
  all_names.map(&:downcase).uniq.join(" ")
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

CHARA_DISP_NAME_TO_ROMANTRANS = {
  "六" => "Roku",
  "どすえ" => "Dosue",
  "Ｂｉｓ子" => "Bisko",
  "文彦さん" => "Fumihiko-san",
  "ピュアクル囿リップ" => "Purecul Lip",
  "みっちゃん" => "Micchan",
  "てまり" => "Temari",
  "小次郎" => "Kojirou",
}.freeze

def norm_charas(remywiki_chara)
  if CHARA_DISP_NAME_TO_ROMANTRANS[remywiki_chara]
    CHARA_DISP_NAME_TO_ROMANTRANS[remywiki_chara]
  else
    remywiki_chara.gsub("/", " ").downcase
  end
end

def log(s)
  Rails.logger.info "fts: #{s}"
end
