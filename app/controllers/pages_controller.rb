class PagesController < ApplicationController
  before_action :logged_in_user
  before_action :update_all

  def index
    @images          = current_user.images.all          if current_user.images.any?
    @flavors         = current_user.flavors.all         if current_user.flavors.any?
    @clusters        = current_user.clusters.all        if current_user.clusters.any?
    @infrastructures = current_user.infrastructures.all if current_user.infrastructures.any?
    @adapters        = { "Choose" => 0 }
    @infrastructures.each { |inf| @adapters[inf.name] = inf.id } if @infrastructures
  end

  def render_form
    @infrastructure_id = params[:infrastructure_id]
    if @infrastructure_id!="0"
      @imgs  = current_user.images.where(infrastructure_id: @infrastructure_id)
      @flvs =  current_user.flavors.where(infrastructure_id: @infrastructure_id)
    end
    respond_to do |format|
      format.js
    end
  end

  private

    # Method to update all clusters of current user
    def update_all
      clusters = current_user.clusters.all
      clusters.each do |cluster|
        ip = IPAddr.new(cluster[:external_ip], Socket::AF_INET).to_s
        url = "http://"+ip+":8084/progress.log"
        uri     = URI.parse(url)
        request = Net::HTTP::Get.new(uri)
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
          http.request(request)
        end

        state = old_state = cluster[:state]
        if response.code == "200"
          if response.body.to_i == 1
            state = 'READY'
          end
        else
          state = 'CONNECTION_FAILED'
        end

        if(state!=old_state)
          cluster.update_attribute(:state, state)
          cluster.update(user_id, cluster[:uuid], state)
        end
      end
    end

    # Method to convert string ip address to int
    def convert_ip(addr)
      addr!=nil && addr!="none" ? IPAddr.new(addr).to_i : nil
    end

end
