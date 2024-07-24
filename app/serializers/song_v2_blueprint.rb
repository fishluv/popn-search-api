class SongV2Blueprint < Blueprinter::Base
  def self.render_if_present(rec, blueprint_class)
    rec.nil? ? nil : blueprint_class.render_as_hash(rec)
  end

  identifier :id

  fields(*%i[
    title
    remywiki_title
    genre
    genre_romantrans
    artist
    debut
    folder
    slug
    remywiki_url_path
    remywiki_chara
    labels
  ])

  field :fw_title, name: :sort_title
  field :fw_genre, name: :sort_genre

  field :character1 do |song|
    render_if_present(song.character1, CharacterBlueprint)
  end

  field :character2 do |song|
    render_if_present(song.character2, CharacterBlueprint)
  end

  field :charts do |song|
    charts = song.charts
    {
      "e" => render_if_present(charts.find { _1.difficulty == "e" }, ChartV2Blueprint),
      "n" => render_if_present(charts.find { _1.difficulty == "n" }, ChartV2Blueprint),
      "h" => render_if_present(charts.find { _1.difficulty == "h" }, ChartV2Blueprint),
      "ex" => render_if_present(charts.find { _1.difficulty == "ex" }, ChartV2Blueprint),
    }
  end
end
