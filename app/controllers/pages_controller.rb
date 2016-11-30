class PagesController < ApplicationController
  # Before rendering dashboard checks if user logged in
  before_action :logged_in_user

  # Retrieves all resources that needs to be shown on dashboard
  def index

  end

  def debug
    @images          = Image.all
    @flavors         = Flavor.all
    @clusters        = current_user.clusters.all        if current_user.clusters.any?
    @infrastructures = current_user.infrastructures.all if current_user.infrastructures.any?
    @adapters        = { "Choose" => 0 }
    @infrastructures.each { |inf| @adapters[inf.name] = inf.id } if @infrastructures
  end

  def faq

  end
end
