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
      update_attribute(data.uuid, data.state)
    if data.type == 3
      add_new_assignment data.user

  add_new_cluster: (cluster) ->
    $("#cluster-panel").append cluster
    $("#new-cluster").modal('hide')

  update_cluster_state: (uuid, state) ->
    $(uuid).html("<strong>#{state}</strong>")
    if state.downcase.include? 'ready'
      $(uuid).attr("class", "text-success")
    if state.downcase.include? 'fail'
      $(uuid).attr("class", "text-danger")

  add_new_assignment: (user) ->
    $("#assignment_email").val("")
    $("#assignment-list").append user

