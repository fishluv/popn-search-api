class ChartBlueprint < Blueprinter::Base
  identifier :id

  fields *%i[
    difficulty
    level
    hyrorre_page_path
    labels
  ]

  field :song do |chart|
    SongBlueprint.render_as_hash(chart.song)
  end

  field :has_holds do |chart|
    chart.has_holds == 1
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
