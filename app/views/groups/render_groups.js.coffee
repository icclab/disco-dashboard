$("#modal-title").html("Assign to group");
$("#modal-body").empty();
$("#modal-body").append("<%= escape_javascript(render(:partial => 'groups/list')) %>");
