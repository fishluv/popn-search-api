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

  def to_s
    "<Chart #{[song.remywiki_title, difficulty, level].compact.join(' ')}>"
  end
end
