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

  scope :search, ->(str) do
    self
      .joins("join fts_charts on charts.id = fts_charts.id")
      .where("fts_charts match ?", str)
      .order(:rank)
  end

  def to_s
    "<Chart #{[song.remywiki_title, difficulty, level].compact.join(' ')}>"
  end
end
