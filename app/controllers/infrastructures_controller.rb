class InfrastructuresController < ApplicationController
  def index
    @infrastructures = current_user.infrastructures.all
  end

  def show
    @infrastructure = Infrastructure.find(params[:infrastructure][:id])
  end

  def new
    #@infrastructure = Infrastructure.new
  end

  def create
    @infrastructure = current_user.infrastructures.build(infrastructure_params)
    @infrastructure.adapter = params[:infrastructure][:type]
    if @infrastructure.save && connection = @infrastructure.authenticate(params[:infrastructure])
      save_images   @infrastructure.get_images   connection
      save_flavors  @infrastructure.get_flavors  connection
      save_keypairs @infrastructure.get_keypairs connection
      flash[:success] = "New infrastructure was added successfully"
    else
      flash[:danger] = "Please, fill all fields with correct information"
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
          size:   img[:minDisk] )

        image.save
      end
    end

    def save_flavors(flavors)
      flavors.each do |flv|
        flavor = @infrastructure.flavors.build(
          fl_id: flv[:id],
          name:  flv[:name],
          vcpus: flv[:vcpus],
          ram:   flv[:ram],
          disk:  flv[:disk] )

        flavor.save
      end
    end

    def save_keypairs(keypairs)
      keypairs.each do |key, value|
        keypair = @infrastructure.keypairs.build(
          name: value[:name]
        ) if !value[:fingerprint].eql? ENV["fingerprint"]

        keypair.save if keypair
      end
    end
end
