module DiscoHelper
  def create_req(cluster, infrastructure)
    uri     = URI.parse(ENV["disco_ip"])
    request = Net::HTTP::Post.new(uri)

    request.content_type         = "text/occi"
    request["Category"]          = 'haas; scheme="http://schemas.cloudcomplab.ch/occi/sm#"; class="kind";'
    request["X-Tenant-Name"]     = infrastructure[:tenant]
    request["X-Region-Name"]     = infrastructure[:region]
    request["X-User-Name"]       = infrastructure[:username]
    request["X-Password"]        = cluster[:password]

    master_image = Image.find(cluster[:master_image])
    request["X-Occi-Attribute"]  = 'icclab.haas.master.image="'+master_image.img_id+'",'
    slave_image = Image.find(cluster[:slave_image])
    request["X-Occi-Attribute"] += 'icclab.haas.slave.image="'+slave_image.img_id+'",'

    request["X-Occi-Attribute"] += 'icclab.haas.master.sshkeyname="'+cluster[:keypair]+'",'

    master_flavor = Flavor.find(cluster[:master_flavor])
    request["X-Occi-Attribute"] += 'icclab.haas.master.flavor="'+master_flavor.fl_id+'",'
    slave_flavor = Flavor.find(cluster[:slave_flavor])
    request["X-Occi-Attribute"] += 'icclab.haas.slave.flavor="'+slave_flavor.fl_id+'",'

    request["X-Occi-Attribute"] += 'icclab.haas.master.number="'+cluster[:master_num].to_s+'",'
    request["X-Occi-Attribute"] += 'icclab.haas.slave.number="'+cluster[:slave_num].to_s+'",'

    request["X-Occi-Attribute"] += 'icclab.haas.master.slaveonmaster="'+value(cluster[:slave_on_master])+'",'

    frameworks = Framework.all
    frameworks.each do |framework|
      if !framework.name.eql? "HDFS"
        request["X-Occi-Attribute"] += 'icclab.disco.frameworks.'+framework[:name].downcase
        request["X-Occi-Attribute"] += '.included="'+value(cluster[framework[:name]])+'",'
      end
    end

    request["X-Occi-Attribute"] += 'icclab.haas.master.withfloatingip="true"'

    Rails.logger.debug {"Cluster attributes: #{request["X-Occi-Attribute"].inspect}"}

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end

    response
  end

  def delete_req(infrastructure, password, uuid)
    uri  = URI.parse(ENV["disco_ip"]+uuid)

    request = Net::HTTP::Delete.new(uri)
    request.content_type     = "text/occi"
    request["Category"]      = 'haas; scheme="http://schemas.cloudcomplab.ch/occi/sm#"; class="kind";'
    request["X-Tenant-Name"] = infrastructure[:tenant]
    request["X-Region-Name"] = infrastructure[:region]
    request["X-User-Name"]   = infrastructure[:username]
    request["X-Password"]    = password

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end

    response
  end

  def send_request(cluster, infrastructure, uuid = '')
    url = ENV["disco_ip"]+uuid
    uri     = URI.parse(url)
    request = Net::HTTP::Get.new(uri)
    request["X-User-Name"]   = infrastructure[:username]
    request["X-Password"]    = cluster[:password]
    request["X-Tenant-Name"] = infrastructure[:tenant]
    request["X-Region-Name"] = infrastructure[:region]
    request["Accept"]        = "text/occi"
    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end

    response
  end

  def value(val)
    val.to_i==1 ? "true" : "false"
  end
end
