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
    if data.type == 2
      $(data.uuid).html("<strong>#{data.state}</strong>")
      if data.state.downcase.include? 'ready'
        $(data.uuid).attr("class", "text-success")
      if data.state.downcase.include? 'fail'
        $(data.uuid).attr("class", "text-danger")
    if data.type == 3
      $("#assignment-list").append data.user
