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

module SessionsHelper

  # Logs in the user
  def log_in(user)
    cookies.signed[:user_id] = user.id
  end

  # Returns true of the given user is the current user.
  def current_user?(user)
    user == current_user
  end

  # Returns current user if any
  def current_user
    @current_user ||= User.find_by(id: cookies.signed[:user_id])
  end

  # Returns current user id
  def current_user_id
    current_user[:id]
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

  # Logs out the current user
  def log_out
    cookies.delete(:user_id)
    @current_user = nil
  end
end
