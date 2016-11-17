class PagesController < ApplicationController
  # Before rendering dashboard checks if user logged in
  before_action :logged_in_user

  # Retrieves all resources that needs to be shown on dashboard
  def index
    @images          = Image.all
    @flavors         = Flavor.all
    @clusters        = current_user.clusters.all        if current_user.clusters.any?
    @infrastructures = current_user.infrastructures.all if current_user.infrastructures.any?
    @adapters        = { "Choose" => 0 }
    @infrastructures.each { |inf| @adapters[inf.name] = inf.id } if @infrastructures
  end

  # Retrieves data and renders a form for a cluster creation
  # Called by AJAX Get request from dashboard
  def render_form
    @infrastructure_id = params[:infrastructure_id]
    if @infrastructure_id != "0"
      @frameworks = Framework.all
      @images     = Image.where(infrastructure_id: @infrastructure_id)
      @flavors    = Flavor.where(infrastructure_id: @infrastructure_id)
      @keypairs   = Keypair.where(infrastructure_id: @infrastructure_id)
    end

    respond_to do |format|
      format.js
    end
  end

end
