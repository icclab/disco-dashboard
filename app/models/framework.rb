class Framework < ApplicationRecord
  validates :name, presence: true
  validates :port, presence: true
end
