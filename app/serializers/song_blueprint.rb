class SongBlueprint < Blueprinter::Base
  def self.render_if_present(rec, blueprint_class)
    rec.nil? ? nil : blueprint_class.render_as_hash(rec)
  end

  identifier :id

  fields(*%i[
    title
    fw_title
    r_title
    remywiki_title
    genre
    fw_genre
    r_genre
    artist
    r_chara
    debut
    folders
    slug
    remywiki_url_path
    labels
  ])

  # deprecated. remove soon.
  field :fw_title, name: :sort_title
  field :fw_genre, name: :sort_genre
  field :r_genre, name: :genre_romantrans
  field :r_chara, name: :remywiki_chara

  field :character1 do |song|
    render_if_present(song.character1, CharacterBlueprint)
  end

  field :character2 do |song|
    render_if_present(song.character2, CharacterBlueprint)
  end

  view :with_charts do
    field :charts do |song|
      charts = song.charts
      {
        "e" => render_if_present(charts.find { _1.difficulty == "e" }, ChartBlueprint),
        "n" => render_if_present(charts.find { _1.difficulty == "n" }, ChartBlueprint),
        "h" => render_if_present(charts.find { _1.difficulty == "h" }, ChartBlueprint),
        "ex" => render_if_present(charts.find { _1.difficulty == "ex" }, ChartBlueprint),
      }
    end
  end
end
