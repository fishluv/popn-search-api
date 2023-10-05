# == Schema Information
#
# Table name: charts
#
#  id                :text             primary key
#  difficulty        :text             not null
#  level             :integer          not null
#  has_holds         :integer          not null
#  song_id           :integer          not null
#  hyrorre_page_path :text
#
class Chart < ApplicationRecord
  belongs_to :song
  belongs_to :hyrorre_chart, foreign_key: "hyrorre_page_path"

  scope :search, ->(query) do
    weights = [
      0, # id
      0.5, # song_id
      1, # folder
      1, # title_genre
      1, # artist
      1, # extra
      1, # difficulty
      1, # level
    ]
    self
      .joins("join fts_charts on charts.id = fts_charts.id")
      .where("fts_charts match #{Fts.match_string(query)}")
      .order(Arel.sql("bm25(fts_charts, #{weights.join(",")})"))
  end

  def labels
    @labels ||= Label.where(record_type: "chart", record_id: id).pluck(:value)
  end

  def to_s
    "<Chart #{[song.remywiki_title, difficulty, level].compact.join(' ')}>"
  end
end
