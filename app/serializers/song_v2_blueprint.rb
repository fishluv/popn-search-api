class SongV2Blueprint < Blueprinter::Base
  identifier :id

  view :search do
    field :folder
    field :remywiki_title, name: :remywikiTitle
    field :easy_diff, name: :easyLevel
    field :normal_diff, name: :normalLevel
    field :hyper_diff, name: :hyperLevel
    field :ex_diff, name: :exLevel
  end

  view :fetch do
    fields *%i[
      title
      genre
      artist
      folder
      labels
    ]

    field :remywiki_title, name: :remywikiTitle
    field :genre_romantrans, name: :romantransGenre
    field :easy_diff, name: :easyLevel
    field :normal_diff, name: :normalLevel
    field :hyper_diff, name: :hyperLevel
    field :ex_diff, name: :exLevel
    field :remywiki_url_path, name: :remywikiPath

    field :titleSortChar do |song|
      song.fw_title[0]
    end

    field :genreSortChar do |song|
      song.fw_genre[0]
    end

    field :character do |song|
      CharacterBlueprint.render_as_hash(song.character1)
    end

    field :easyChartId do |song|
      "#{song.id}e" if song.easy_diff
    end

    field :normalChartId do |song|
      "#{song.id}n" if song.normal_diff
    end

    field :hyperChartId do |song|
      "#{song.id}h" if song.hyper_diff
    end

    field :exChartId do |song|
      "#{song.id}ex" if song.ex_diff
    end
  end
end
