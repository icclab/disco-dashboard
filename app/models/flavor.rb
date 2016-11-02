class Flavor < ApplicationRecord
  belongs_to :infrastructure

  validates :fl_id, presence: true
  validates :name,  presence: true
  validates :vcpus, presence: true
  validates :disk,  presence: true
  validates :ram,   presence: true
end
