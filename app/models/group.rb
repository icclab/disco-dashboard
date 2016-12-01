class Group < ApplicationRecord
  has_many :assignments
  has_many :users, through: :assignments
  has_many :clusters
end
