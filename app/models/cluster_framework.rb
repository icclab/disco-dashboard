##
# ClusterFramework model is used to assign frameworks to the cluster
# by using many-to-many relationship between clusters and framework.
class ClusterFramework < ApplicationRecord
  belongs_to :cluster
  belongs_to :framework
end
