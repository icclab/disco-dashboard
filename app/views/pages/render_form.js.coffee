$("#cluster-form").empty()
$("#form-body").append("<%= escape_javascript(render(:partial => 'clusters/form')) %>")
