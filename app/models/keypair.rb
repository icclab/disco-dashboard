class Keypair < ApplicationRecord
  belongs_to :infrastructure

  validates :name, presence: true
end
