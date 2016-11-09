module ClusterHelper
  # Checks link for being broken or not.
  # Returns "text-success" if link is working,
  #         "text-danger"  if link is broken.
  def check_link(url)
    uri = URI.parse(url)
    response = nil
    begin
      Net::HTTP.start(uri.host, uri.port) { |http|
        response = http.head(uri.path.size > 0 ? uri.path : "/")
      }
    rescue Errno::ECONNREFUSED
      return "text-danger"
    end
    "text-success"
  end

  def cluster_owner?(id)
    current_user.infrastructures.any? && current_user.infrastructures.exists?(infrastructure_id: id)
  end
end
