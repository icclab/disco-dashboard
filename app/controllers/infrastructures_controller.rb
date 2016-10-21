class InfrastructuresController < ApplicationController
  def create
    @infrastructure = current_user.infrastructures.build(infrastructure_params)
    if @infrastructure.save
      connection = authenticate(@infrastructure, password)

      save_images  connection.get_images()
      save_flavors connection.get_flavors()
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

    def authenticate(infrastructure, password)
      os = current_user.infrastructures.find_by(id: id)
      return OpenStack::Connection.create ({
        username:   infrastructure[:username],
        api_key:    password,
        auth_url:   infrastructure[:auth_url],
        authtenant: infrastructure[:tenant]
      })
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
