# == Schema Information
#
# Table name: songs
#
#  id                :integer          primary key
#  artist            :text             not null
#  chara1            :text             not null
#  debut             :text             not null
#  deleted           :integer          default(0), not null
#  easy_diff         :integer
#  easy_hold_flag    :integer
#  ex_diff           :integer
#  ex_hold_flag      :integer
#  folder            :text
#  fw_artist         :text             not null
#  fw_genre          :text             not null
#  fw_title          :text             not null
#  genre             :text             not null
#  genre_romantrans  :text
#  genre_sort_char   :text             not null
#  hyper_diff        :integer
#  hyper_hold_flag   :integer
#  normal_diff       :integer
#  normal_hold_flag  :integer
#  remywiki_chara    :text
#  remywiki_title    :text
#  remywiki_url_path :text
#  slug              :text
#  title             :text             not null
#  title_sort_char   :text             not null
#
class Song < ApplicationRecord
  has_many :charts

  scope :search, ->(query) do
    weights = [
      0, # id
      0.5, # id_pad
      1, # debut
      1, # folder
      1, # title_genre
      0.75, # artist
      1, # extra
      1, # diffs_levels
      1, # chara1_disp_name
      0.75, # charas_romantrans
    ]
    self
      .joins("join fts_songs on songs.id = fts_songs.id")
      .where("fts_songs match #{Fts.match_string(query)}")
      .order(Arel.sql("bm25(fts_songs, #{weights.join(",")})"))
  end

  def character1
    @character ||= Character.find_by(chara_id: chara1)
  end

  def labels
    @labels ||= Label.where(record_type: "song", record_id: id).pluck(:value)
  end

  def to_s
    display_genre = "[#{genre_romantrans}]" unless remywiki_title == genre_romantrans
    "<Song #{[id, remywiki_title, display_genre, artist].compact.join(' ')}>"
  end
end
