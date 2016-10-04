class DeploymentProgressJob < ApplicationJob
  queue_as :default

  def perform(username, password, tenant, disco_uri, cluster_id)
    # Do something later
  end
end
