class InfrastructuresController < ApplicationController
  def create
    @infrastructure = current_user.infrastructures.build(infrastructure_params)
    if @infrastructure.save
      connection = @infrastucture.authenticate(params[:password])

      save_images  @infrastructure.get_images  connection
      save_flavors @infrastructure.get_flavors connection
      #todo
    else
      #todo
    end
  end

  def destroy
    Infrastructure.find(params[:id]).destroy
    redirect_to root_url
  end

  private
    def infrastructure_params
      params.require(:infrastructure).permit(:name, :username, :tenant, :auth_url)
    end

    def save_images(images)
      images.each do |img|
        image = current_user.images.build(
          img_id: img[:id],
          name:   img[:name],
          size:   img[:size]
        )

        if image.save
          # gj
        else
          #not gj
        end
      end
    end

    def save_flavors(flavors)
      flavors.each do |flv|
        flavor = current_user.flavors.build(
          fl_id: flv[:id],
          name:  flv[:name],
          vcpus: flv[:vcpus],
          ram:   flv[:ram],
          disk:  flv[:disk]
        )

        if flavor.save
        else
        end
      end
    end
end
