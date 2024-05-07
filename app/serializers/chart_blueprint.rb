class ChartBlueprint < Blueprinter::Base
  identifier :id

  fields(*%i[
    difficulty
    level
    bpm
    bpm_steps
    duration
    notes
    hold_notes
    jkwiki_page_path
    labels
  ])

  field :song do |chart|
    SongBlueprint.render_as_hash(chart.song)
  end

  field :has_holds do |chart|
    chart.hold_notes > 0
  end

  field :rating do |chart|
    chart.jkwiki_chart&.rating
  end

  field :sran_level do |chart|
    chart.jkwiki_chart&.sran_level
  end
end
