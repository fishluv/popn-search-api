# == Schema Information
#
# Table name: labels
#
#  id          :integer          primary key
#  record_type :text             not null
#  record_id   :integer          not null
#  value       :text             not null
#
class Label < ApplicationRecord
end
