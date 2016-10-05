App.cluster = App.cable.subscriptions.create "ClusterChannel",
  connected: ->
    # Called when the subscription is ready for use on the server
    $(document).alert("Cluster is being deployed")

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    html = if data["progress"]==100 then @completed(data) else @updateInfo(data)
    id = "#"+data["id"]
    $("#{id}").html(html)

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
