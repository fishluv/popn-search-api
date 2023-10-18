class SongBlueprint < Blueprinter::Base
  identifier :id

  fields(
    :title,
    :genre,
    :artist,
    :easy_diff,
    :normal_diff,
    :hyper_diff,
    :ex_diff,
    :folder,
    :slug,
    :remywiki_url_path,
    :remywiki_title,
    :genre_romantrans,
    :labels,
  )

  field :title_sort_char do |song|
    song.fw_title[0]
  end

  field :genre_sort_char do |song|
    song.fw_genre[0]
  end
end
