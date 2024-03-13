class SongBlueprint < Blueprinter::Base
  identifier :id

  fields *%i[
    title
    title_sort_char
    remywiki_title
    genre
    genre_sort_char
    genre_romantrans
    artist
    easy_diff
    normal_diff
    hyper_diff
    ex_diff
    debut
    folder
    slug
    remywiki_url_path
    remywiki_chara
    labels
  ]

  # TODO: Delete
  field :character do |song|
    song.character1.nil? ? nil : CharacterBlueprint.render_as_hash(song.character1)
  end

  field :character1 do |song|
    song.character1.nil? ? nil : CharacterBlueprint.render_as_hash(song.character1)
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
