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
      if date.state.downcase.include? 'ready'
        $(data.uuid).attr("class", "text-success")
      if date.state.downcase.include? 'fail'
        $(data.uuid).attr("class", "text-danger")
