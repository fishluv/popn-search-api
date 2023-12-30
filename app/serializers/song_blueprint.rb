class SongBlueprint < Blueprinter::Base
  identifier :id

  fields *%i[
    title
    remywiki_title
    genre
    genre_romantrans
    artist
    easy_diff
    normal_diff
    hyper_diff
    ex_diff
    folder
    slug
    remywiki_url_path
    remywiki_chara
    labels
  ]

  field :title_sort_char do |song|
    song.fw_title[0]
  end

  field :genre_sort_char do |song|
    song.fw_genre[0]
  end

  # TODO: Delete
  field :character do |song|
    CharacterBlueprint.render_as_hash(song.character1)
  end

  field :character1 do |song|
    CharacterBlueprint.render_as_hash(song.character1)
  end

  field :easy_chart_id do |song|
    "#{song.id}e" if song.easy_diff
  end

  field :normal_chart_id do |song|
    "#{song.id}n" if song.normal_diff
  end

  field :hyper_chart_id do |song|
    "#{song.id}h" if song.hyper_diff
  end

  field :ex_chart_id do |song|
    "#{song.id}ex" if song.ex_diff
  end
end
