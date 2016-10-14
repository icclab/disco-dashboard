App.cluster = App.cable.subscriptions.create "ClusterChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    if data.type == 1
      $("#cluster-panel").append data.cluster
      $("#new-cluster").modal('hide')
    else
      $(data.uuid).html("<strong>#{data.state}</strong>")

    if date.state=="CREATE_COMPLETE"
      $(data.uuid).attr("class", "text-success")

  new_cluster: (data) ->
    """
      <div class="col-lg-4">
        <a data-toggle="modal" data-target=".bs-cluster-modal"
        data-remote="true" href="/details?uuid=#{ data["uuid"] }">
          <div class="panel panel-info" id="#{ data["uuid"] }">
            <div class="panel-heading">
              #{ data["info"]["name"] }
            </div>
            <div class="panel-body text-left">
              <dl class="dl-horizontal">
                <dt>Master Image</dt>
                <dd>#{ data["info"]["m_image"] }</dd>
                <dt>Master VCPUs</dt>
                <dd>#{ data["info"]["m_vcpus"] }</dd>
                <dt>Master RAM</dt>
                <dd>#{ data["info"]["m_ram"] }</dd>
                <dt>Master Disk</dt>
                <dd>#{ data["info"]["m_disk"] }</dd>
                <dt>Slave Image</dt>
                <dd>#{ data["info"]["s_image"] }</dd>
                <dt>Slave VCPUs</dt>
                <dd>#{ data["info"]["s_vcpus"] }</dd>
                <dt>Slave RAM</dt>
                <dd>#{ data["info"]["s_ram"] }</dd>
                <dt>Slave Disk</dt>
                <dd>#{ data["info"]["s_disk"] }</dd>
                <dt>Status</dt>
                <dd id="cluster-#{ data["uuid"] }" class="text-warning">
                  Deployment...
                </dd>
              </dl>
            </div>
          </div>
        </a></div>
    """
###
  updateInfo: (data) ->
    """
    <div class="panel-body text-left">
        <div class="progress progress-striped active">
          <div class="progress-bar progress-bar-success" role="progressbar" aria-valuenow="#{data["progress"]}" aria-valuemin="0" aria-valuemax="100" style="width: #{data["progress"]}%">
              <span class="sr-only">#{data["progress"]}% Complete (success)</span>
          </div>
      </div>
      <p>
        #{data["status"]}
      </p>
    </div>
    """

  completed: (data) ->
    """
    <div class="panel-body text-left">
        <dl class="dl-horizontal">
            <dt>Master Image</dt>
            <dd>#{data["m_image"]}</dd>
            <dt>Master VCPUs</dt>
            <dd>#{data["m_vcpus"]}</dd>
            <dt>Master RAM</dt>
            <dd>#{data["m_ram"]}MB</dd>
            <dt>Master Disk</dt>
            <dd>#{data["m_disk"]}GB</dd>
            <dt>Slave Image</dt>
            <dd>#{data["s_image"]}</dd>
            <dt>Slave VCPUs</dt>
            <dd>#{data["s_vcpus"]}</dd>
            <dt>Slave RAM</dt>
            <dd>#{data["s_ram"]}MB</dd>
            <dt>Slave Disk</dt>
            <dd>#{data["s_disk"]}GB</dd>
            <dt>Status</dt>
            <dd class="text-#{data["color"]}"><strong>#{data["status"]}</strong></dd>
        </dl>
    </div>
    """
###
