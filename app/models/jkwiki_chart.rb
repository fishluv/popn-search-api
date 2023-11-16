# == Schema Information
#
# Table name: jkwiki_charts
#
#  bpm          :text             not null
#  category     :text             not null
#  category2    :text
#  difficulty   :text             not null
#  duration     :text
#  duration_sec :integer
#  genre        :text             not null
#  level        :integer          not null
#  notes        :integer
#  page_path    :text             primary key
#  rating       :text
#  rating_num   :decimal(4, 3)
#  sran_level   :text
#  title        :text             not null
#
class JkwikiChart < ApplicationRecord
  has_one :chart, foreign_key: "jkwiki_page_path"

  def to_s
    "<JkwikiChart #{[title, genre == title ? nil : genre, difficulty, level].compact.join(' ')}>"
  end
end
