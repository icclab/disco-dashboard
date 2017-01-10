# AJAX which renders a form according to selected infrastructure during cluster creation process.
$ ->
  $(document).on 'change', '#infrastructure_id', (evt) ->
    $.ajax 'render_form',
      type: 'GET'
      dataType: 'script'
      data: {
        infrastructure_id: $("#infrastructure_id option:selected").val()
      }
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error: #{textStatus}")
      success: (data, textStatus, jqXHR) ->
        console.log("Dynamic images and flavors select OK!")
