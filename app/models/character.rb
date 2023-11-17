# == Schema Information
#
# Table name: characters
#
#  id              :integer          primary key
#  disp_name       :text             not null
#  icon1           :text             not null
#  romantrans_name :text
#  sort_char       :text             not null
#  sort_name       :text             not null
#  chara_id        :text             not null
#
class Character < ApplicationRecord
end
