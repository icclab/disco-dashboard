App.cluster = App.cable.subscriptions.create "ClusterChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    if data.type == 1
      add_new_cluster data.cluster
    if data.type == 2
      update_cluster_state(data.uuid, data.state)
    if data.type == 3
      add_new_assignment data.user
    if data.type == 4
      remove_assignment(data.clusterId, data.userId)

  add_new_cluster = (cluster) ->
    $("#cluster-panel").append cluster
    $("#new-cluster").modal('hide')

  update_cluster_state = (uuid, state) ->
    $("#"+uuid).html("#{state}")
    $("#circle-"+uuid).attr("class", "circle-info pull-right")
    if state.indexOf('READY') != -1
      $("#circle-"+uuid).attr("class", "circle-success pull-right")
    if state.indexOf('FAIL') != -1
      $("#circle-"+uuid).attr("class", "circle-danger pull-right")

  add_new_assignment = (user) ->
    $("#assignment_email").val("")
    $("#assignment-list").append user

  remove_assignment = (clusterId, userId) ->
    assignment = "#{clusterId}-assigned-to-#{userId}"
    $("#"+assignment).remove()

