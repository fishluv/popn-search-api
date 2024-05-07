class SongBlueprint < Blueprinter::Base
  identifier :id

  fields(*%i[
    title
    title_sort_char
    remywiki_title
    genre
    genre_sort_char
    genre_romantrans
    artist
    debut
    folder
    slug
    remywiki_url_path
    remywiki_chara
    labels
  ])

  field :easy_diff do |song|
    song.charts.find { _1.difficulty == "e" }&.level
  end

  field :normal_diff do |song|
    song.charts.find { _1.difficulty == "n" }&.level
  end

  field :hyper_diff do |song|
    song.charts.find { _1.difficulty == "h" }&.level
  end

  field :ex_diff do |song|
    song.charts.find { _1.difficulty == "ex" }&.level
  end

  field :character1 do |song|
    song.character1.nil? ? nil : CharacterBlueprint.render_as_hash(song.character1)
  end

  field :character2 do |song|
    song.character2.nil? ? nil : CharacterBlueprint.render_as_hash(song.character2)
  end
end
