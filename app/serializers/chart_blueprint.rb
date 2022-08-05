class ChartBlueprint < Blueprinter::Base
  identifier :id
  field :difficulty
  field :level
  field :has_holds

  field :song_id do |chart|
    chart.song.id
  end

  field :artist do |chart|
    chart.song.artist
  end

  field :genre_romantrans do |chart|
    chart.song.genre_romantrans
  end

  field :remywiki_title do |chart|
    chart.song.remywiki_title
  end

  field :remywiki_url_path do |chart|
    chart.song.remywiki_url_path
  end

  field :category do |chart|
    chart.hyrorre_chart&.category
  end

  field :bpm do |chart|
    chart.hyrorre_chart&.bpm
  end

  field :duration do |chart|
    chart.hyrorre_chart&.duration
  end

  field :notes do |chart|
    chart.hyrorre_chart&.notes
  end

  field :rating do |chart|
    chart.hyrorre_chart&.rating
  end

  field :sran_level do |chart|
    chart.hyrorre_chart&.sran_level
  end
end
