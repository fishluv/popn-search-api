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
    labels
  ]

  field :title_sort_char do |song|
    song.fw_title[0]
  end

  field :genre_sort_char do |song|
    song.fw_genre[0]
  end

  field :character do |song|
    CharacterBlueprint.render_as_hash(song.character)
  end
end
