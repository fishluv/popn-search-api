class ChartBlueprint < Blueprinter::Base
  identifier :id

  fields(*%i[
    difficulty
    level
    bpm
    bpm_main
    bpm_main_type
    duration
    notes
    hold_notes
    timesig_main
    timesig_main_type
    timing
    jkwiki_page_path
    labels
  ])

  field :bpm_steps do |chart|
    chart.bpm_steps.split(",").map(&:to_i)
  end

  field :timesig_steps do |chart|
    JSON.parse(chart.timesig_steps)
  rescue
    []
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

  view :with_song_and_other_charts do
    include_view :with_song

    field :other_charts do |chart|
      {
        "e" => chart.song.charts.find { _1.difficulty == "e" },
        "n" => chart.song.charts.find { _1.difficulty == "n" },
        "h" => chart.song.charts.find { _1.difficulty == "h" },
        "ex" => chart.song.charts.find { _1.difficulty == "ex" },
      }
        .compact
        .except(chart.difficulty)
        .transform_values { _1.level }
    end
  end
end
