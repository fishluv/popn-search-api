class ChartV2Blueprint < Blueprinter::Base
  identifier :id

  view :search do
    fields *%i[
      difficulty
      level
    ]

    field :song do |chart|
      SongV2Blueprint.render_as_hash(chart.song, view: :search).slice(:folder, :remywikiTitle)
    end
  end

  view :fetch do
    fields *%i[
      difficulty
      level
      labels
    ]

    field :jkwiki_page_path, name: :jkwikiPath

    field :hasHolds do |chart|
      chart.has_holds == 1
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

    field :jpRating do |chart|
      chart.jkwiki_chart&.rating
    end

    field :sranLevel do |chart|
      chart.jkwiki_chart&.sran_level
    end

    field :song do |chart|
      SongV2Blueprint.render_as_hash(chart.song, view: :fetch)
    end
  end
end
