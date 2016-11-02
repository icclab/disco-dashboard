class Image < ApplicationRecord
  belongs_to :infrastructure

  validates :img_id, presence: true
  validates :name,   presence: true
end
