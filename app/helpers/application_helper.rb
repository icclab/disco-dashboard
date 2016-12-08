module ApplicationHelper

  # Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = "DISCO";
    if page_title.empty?
      base_title
    else
      page_title+" | "+base_title
    end
  end

  # Formats JSON
  def format_json(json)
    JSON.pretty_generate(json)
  end

  # To get right status according to a state
  def get_status(state)
    state ||= 'info'
    if state.downcase.include? "failed"
      'danger'
    elsif state.downcase.include?("create_complete")||state.downcase.include?("ready")
      'success'
    else
      'info'
    end
  end

end
