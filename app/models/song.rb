# == Schema Information
#
# Table name: songs
#
#  id                :integer          primary key
#  artist            :text             not null
#  categories        :integer          not null
#  chara1            :text             not null
#  chara2            :text             not null
#  cs_version        :integer          not null
#  debut             :text             not null
#  folder            :integer          not null
#  fw_artist         :text             not null
#  fw_genre          :text             not null
#  fw_title          :text             not null
#  genre             :text             not null
#  genre_romantrans  :text
#  remywiki_chara    :text
#  remywiki_title    :text
#  remywiki_url_path :text
#  slug              :text
#  title             :text             not null
#  version_folder    :text
#
class Song < ApplicationRecord
  has_many :charts

  CATEGORIES_BIT_VALUES = {
    # In-game order
    # https://github.com/CrazyRedMachine/popnhax_tools/blob/8c424ae3a97ed907ec0bee63b1d12a077e023f63/omnimix/omnimix_db.md#music-database-format
    "iidx" =>       0x0002,
    "ddr" =>        0x0004,
    "gitadora" =>   0x0008,
    "jubeat" =>     0x0800,
    "reflec" =>     0x1000,
    "sdvx" =>       0x2000,
    "beatstream" => 0x4000,
    "museca" =>     0x8000,
    "nostalgia" => 0x10000,
    "bemani" =>     0x07f1,
  }.freeze

  scope :in_folder, ->(folder) { where("categories & ? != 0", CATEGORIES_BIT_VALUES[folder]) }

  scope :search, ->(query, join: true) do
    weights = [
      0, # id
      0.5, # id_pad
      1, # debut
      1, # version_folder
      1, # title_genre
      0.75, # artist
      1, # extra
      1, # diffs_levels
      1, # chara1_disp_name
      0.75, # charas_romantrans
    ]

    scope = self
    scope = scope.joins("join fts_songs on songs.id = fts_songs.id") if join
    scope
      .where("fts_songs match #{Fts.match_string(query, "diffs_levels")}")
      .order(Arel.sql("bm25(fts_songs, #{weights.join(",")})"))
  end

  def character1
    @character1 ||= Character.find_by(chara_id: chara1)
  end

  def character2
    @character2 ||= Character.find_by(chara_id: chara2)
  end

  def bemani_folders
    CATEGORIES_BIT_VALUES.keys.select { categories & CATEGORIES_BIT_VALUES[_1] != 0 }
  end

  def folders
    [version_folder, *bemani_folders].compact
  end

  def labels
    @labels ||= Label.where(record_type: "song", record_id: id).pluck(:value)
  end

  def to_s
    display_genre = "[#{genre_romantrans}]" unless remywiki_title == genre_romantrans
    "<Song #{[id, remywiki_title, display_genre, artist].compact.join(' ')}>"
  end
end
