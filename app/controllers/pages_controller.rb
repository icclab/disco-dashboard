class PagesController < ApplicationController
  # Before rendering dashboard checks if user logged in
  before_action :logged_in_user

  # Retrieves current user's
  #   - clusters
  #   - infrastructures
  #  to show on the main page
  def index
    @images          = Image.all
    @flavors         = Flavor.all
    @clusters        = current_user.clusters.all        if current_user.clusters.any?
    @infrastructures = current_user.infrastructures.all if current_user.infrastructures.any?
    @adapters        = { "Choose" => 0 }
    @infrastructures.each { |inf| @adapters[inf.name] = inf.id } if @infrastructures
  end

  # Retrieves data and renders a form for a cluster creation
  # Called by AJAX Get request from front-end
  def render_form
    @infrastructure_id = params[:infrastructure_id]
    if @infrastructure_id != "0"
      @frameworks = Framework.all
      @imgs       = Image.where(infrastructure_id: @infrastructure_id)
      @flvs       = Flavor.where(infrastructure_id: @infrastructure_id)
      @keys       = Keypair.where(infrastructure_id: @infrastructure_id)
    end

    respond_to do |format|
      format.js
    end
  end

end
