class InfrastructuresController < ApplicationController
  def create
    @infrastructure = Infrastructure.new
  end

  def destroy

  end

  private
    def infrastructure_params

    end
end
