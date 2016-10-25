class PagesController < ApplicationController
  before_action :logged_in_user

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
    puts @infrastructure
    respond_to do |format|
      format.js
    end
    #render(partial: 'clusters/form', locals: { images:  images,
    #                                           flavors: flavors })
  end

  private

    # Method to update all clusters of current user
    def update_all
      clusters = current_user.clusters.all

      response = send_request

      clusters.each { |cluster| cluster[:uuid] ? send_request(cluster[:uuid]) : cluster.delete }

      clusters.each do |cluster|
        response = send_request(cluster[:uuid], 'json')

        if response.code == "200"
          disco_cluster = JSON.parse(response.body)

          status = disco_cluster["attributes"]["stack_status"]
          ip     = convert_ip(disco_cluster["attributes"]["externalIP"])

          cluster.update_columns(state: status, external_ip: ip)
        else
          cluster.delete
        end
      end
    end

    # Method to convert string ip address to int
    def convert_ip(addr)
      addr!=nil && addr!="none" ? IPAddr.new(addr).to_i : nil
    end

end
