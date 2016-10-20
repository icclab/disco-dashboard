class Infrastructure < ApplicationRecord
  belongs_to :user
  has_many :clusters, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :flavors, dependent: :destroy
end
