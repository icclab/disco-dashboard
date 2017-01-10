App.cluster = App.cable.subscriptions.create "ClusterChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    update_cluster_state(data.uuid, data.state)

  update_cluster_state = (uuid, state) ->
    # Called to update some cluster's state and change status circle according to the state
    $("#"+uuid).html("#{state}")
    $("#circle-"+uuid).attr("class", "circle-info pull-right")
    if state.indexOf('READY') != -1
      $("#circle-"+uuid).attr("class", "circle-success pull-right")
    if state.indexOf('FAIL') != -1
      $("#circle-"+uuid).attr("class", "circle-danger pull-right")

