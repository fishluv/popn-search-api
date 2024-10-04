class ChartBlueprint < Blueprinter::Base
  identifier :id

  fields(*%i[
    difficulty
    level
    bpm
    bpm_primary
    bpm_primary_type
    duration
    notes
    hold_notes
    timing
    jkwiki_page_path
    labels
  ])

  field :bpm_steps do |chart|
    chart.bpm_steps.split(",").map(&:to_i)
  end

  field :timing_steps do |chart|
    JSON.parse(chart.timing_steps)
  rescue
    []
  end

  field :rating do |chart|
    chart.jkwiki_chart&.rating
  end

  field :sran_level do |chart|
    chart.jkwiki_chart&.sran_level
  end

  view :with_song do
    field :song do |chart|
      SongBlueprint.render_as_hash(chart.song)
    end
  end
end
