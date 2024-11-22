# == Schema Information
#
# Table name: charts
#
#  id                     :text             primary key
#  bpm                    :text
#  bpm_primary            :integer
#  bpm_primary_type       :text
#  bpm_steps              :text
#  difficulty             :text             not null
#  duration               :integer
#  filename               :text
#  folder                 :text
#  force_new_chart_format :integer
#  hardest                :integer          not null
#  hold_notes             :integer
#  jkwiki_page_path       :text
#  level                  :integer          not null
#  notes                  :integer
#  timing                 :text
#  timing_steps           :text
#  song_id                :integer          not null
#
# Foreign Keys
#
#  jkwiki_page_path  (jkwiki_page_path => jkwiki_charts.page_path)
#  song_id           (song_id => songs.id)
#
class Chart < ApplicationRecord
  belongs_to :song
  belongs_to :jkwiki_chart, foreign_key: "jkwiki_page_path"

  scope :search, ->(query, join: true) do
    weights = [
      0, # id
      0.5, # song_id
      1, # song_debut
      1, # song_folders
      1, # title_genre
      0.5, # artist
      1, # extra
      1, # difficulty
      1, # level
      1, # chara1_disp_name
      0.75, # charas_romantrans
    ]

    scope = self
    scope = scope.joins("join fts_charts on charts.id = fts_charts.id") if join
    scope
      .where("fts_charts match #{Fts.match_string(query, "level")}")
      .order(Arel.sql("bm25(fts_charts, #{weights.join(",")})"))
  end

  def labels
    @labels ||= Label.where(record_type: "chart", record_id: id).pluck(:value)
  end

  def to_s
    "<Chart #{[song.remywiki_title, difficulty, level].compact.join(' ')}>"
  end
end
