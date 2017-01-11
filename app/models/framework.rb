# Framework model relationships and validations
class Framework < ApplicationRecord
  has_many  :cluster_frameworks
  validates :name, presence: true
  validates :port, presence: true
end
