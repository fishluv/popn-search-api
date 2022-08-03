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
  def to_s
    display_genre = "[#{genre_romantrans}]" unless remywiki_title == genre_romantrans
    "<Song #{[id, remywiki_title, display_genre, artist].compact.join(' ')}>"
  end
end
