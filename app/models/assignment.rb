##
# Assignment model is used to assign users to groups and vice-versa
# by creating many-to-many relationship between users and groups
class Assignment < ApplicationRecord
  belongs_to :group
  belongs_to :user
end
