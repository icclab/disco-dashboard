class ClusterFramework < ApplicationRecord
  belongs_to :cluster
  has_one    :framework
end
