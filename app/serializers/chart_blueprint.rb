class ChartBlueprint < Blueprinter::Base
  identifier :id

  fields *%i[
    difficulty
    level
    jkwiki_page_path
    labels
  ]

  field :song do |chart|
    SongBlueprint.render_as_hash(chart.song)
  end

  field :has_holds do |chart|
    chart.has_holds == 1
  end

  field :category do |chart|
    chart.jkwiki_chart&.category
  end

  field :bpm do |chart|
    chart.jkwiki_chart&.bpm
  end

  field :duration do |chart|
    chart.jkwiki_chart&.duration
  end

  field :notes do |chart|
    chart.jkwiki_chart&.notes
  end

  field :rating do |chart|
    chart.jkwiki_chart&.rating
  end

  field :sran_level do |chart|
    chart.jkwiki_chart&.sran_level
  end
end
