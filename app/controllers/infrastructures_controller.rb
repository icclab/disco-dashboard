class InfrastructuresController < ApplicationController
  def new
    #infrastructure = params[:infrastructure].except(:password)
    @infrastructure = current_user.infrastructures.build(infrastructure_params)
    @infrastructure.adapter = params[:infrastructure][:type]
    connection = @infrastructure.authenticate(params[:infrastructure])
    if connection && @infrastructure.save
      save_images  @infrastructure.get_images  connection
      save_flavors @infrastructure.get_flavors connection
      puts "saved successfully"
    else
      puts "something is wrong"
      @infrastructure.delete
    end
    redirect_to root_url
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
        image = @infrastructure.images.build(
          img_id: img[:id],
          name:   img[:name],
          size:   img[:minDisk]
        )
        puts img
        if image.save
          puts "image saved"
          # gj
        else
          #not gj
        end
      end
    end

    def save_flavors(flavors)
      flavors.each do |flv|
        flavor = @infrastructure.flavors.build(
          fl_id: flv[:id],
          name:  flv[:name],
          vcpus: flv[:vcpus],
          ram:   flv[:ram],
          disk:  flv[:disk]
        )
        puts flv
        if flavor.save
          puts "flavor saved"
        else
        end
      end
    end
end
