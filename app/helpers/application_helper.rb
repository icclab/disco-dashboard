#
# Copyright (c) 2015. Zuercher Hochschule fuer Angewandte Wissenschaften
#  All Rights Reserved.
#
#     Licensed under the Apache License, Version 2.0 (the "License"); you may
#     not use this file except in compliance with the License. You may obtain
#     a copy of the License at
#
#          http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#     WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#     License for the specific language governing permissions and limitations
#     under the License.
#

#
#     Author: Saken Kenzhegulov,
#     URL: https://github.com/skenzhegulov
#

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
    if state.downcase.include? "fail"
      'danger'
    elsif state.downcase.include?("complete")||state.downcase.include?("ready")
      'success'
    else
      'info'
    end
  end

end
