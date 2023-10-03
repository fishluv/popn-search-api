# == Schema Information
#
# Table name: songs
#
#  id                :integer          primary key
#  fw_genre          :text             not null
#  fw_title          :text             not null
#  fw_artist         :text             not null
#  genre             :text             not null
#  title             :text             not null
#  artist            :text             not null
#  easy_diff         :integer
#  easy_hold_flag    :integer
#  normal_diff       :integer
#  normal_hold_flag  :integer
#  hyper_diff        :integer
#  hyper_hold_flag   :integer
#  ex_diff           :integer
#  ex_hold_flag      :integer
#  deleted           :integer          default(0)
#  genre_romantrans  :text
#  remywiki_title    :text
#  remywiki_url_path :text
#
class Song < ApplicationRecord
  has_many :charts

  scope :search, ->(str) do
    str.gsub!(/['"]/, "") # Quotes are impossible to handle in fts5.
    weights = [
      0, # id
      0.5, # id_pad
      1, # folder
      1, # title_genre
      1, # artist
      1, # extra
    ]
    self
      .joins("join fts_songs on songs.id = fts_songs.id")
      .where("fts_songs match ?", str)
      .order(Arel.sql("bm25(fts_songs, #{weights.join(",")})"))
  end

  def to_s
    display_genre = "[#{genre_romantrans}]" unless remywiki_title == genre_romantrans
    "<Song #{[id, remywiki_title, display_genre, artist].compact.join(' ')}>"
  end
end
