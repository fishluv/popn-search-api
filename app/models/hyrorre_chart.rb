# == Schema Information
#
# Table name: hyrorre_charts
#
#  page_path  :text             primary key
#  level      :integer          not null
#  difficulty :text             not null
#  category   :text             not null
#  genre      :text             not null
#  title      :text             not null
#  bpm        :text             not null
#  duration   :text
#  notes      :text
#  rating     :text
#  sran_level :text
#
class HyrorreChart < ApplicationRecord
  has_one :chart, foreign_key: "hyrorre_page_path"

  def to_s
    "<HyrorreChart #{[title, genre == title ? nil : genre, difficulty, level].compact.join(' ')}>"
  end
end
