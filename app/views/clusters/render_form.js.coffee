$("#form-body").empty()
$("#form-body").append("<%= escape_javascript(render(:partial => 'clusters/form')) %>")
