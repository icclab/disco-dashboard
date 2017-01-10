##
# Group model relationships and validations
class Group < ApplicationRecord
  has_many :assignments
  has_many :users, through: :assignments
  has_many :clusters
  has_many :tasks, dependent: :destroy

  validates :name, presence: true
end
