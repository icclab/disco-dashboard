module ClusterHelper
  # Checks link for being broken or not.
  # Returns "success" if link is working,
  #         "danger"  if link is broken.
  def check_link(url)
    Rails.logger.debug url
    uri = URI.parse(url)
    response = nil
    begin
      Net::HTTP.start(uri.host, uri.port) { |http|
        response = http.head(uri.path.size > 0 ? uri.path : "/")
      }
    rescue StandardError
      return "danger"
    end
    "success"
  end

end
