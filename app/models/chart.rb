# == Schema Information
#
# Table name: charts
#
#  id               :text             primary key
#  difficulty       :text             not null
#  has_holds        :integer          not null
#  jkwiki_page_path :text
#  level            :integer          not null
#  song_id          :integer          not null
#
# Foreign Keys
#
#  jkwiki_page_path  (jkwiki_page_path => jkwiki_charts.page_path)
#  song_id           (song_id => songs.id)
#
class Chart < ApplicationRecord
  belongs_to :song
  belongs_to :jkwiki_chart, foreign_key: "jkwiki_page_path"

  scope :search, ->(query) do
    weights = [
      0, # id
      0.5, # song_id
      1, # folder
      1, # title_genre
      0.5, # artist
      1, # extra
      1, # difficulty
      1, # level
      1, # chara_disp_name
      0.75, # chara_romantrans_name
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
