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

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  #rescue_from StandardError, :with => :render_500

  include SessionsHelper

  def not_found
    render :file => "#{Rails.root}/public/404.html", :status => 404
  end

  def render_500(exception)
    @exception = exception
    render :file => "#{Rails.root}/public/500.html", :status => 500
  end

  private
    def logged_in_user
      user_id = cookies.signed[:user_id]
      user = User.find_by(id: user_id)
      if user
        log_in user
      end
      unless logged_in?
        redirect_to login_url
      end
    end

    def is_permitted?(method)
      redirect_to root_url if !current_user.send("#{method}_permissions?")
    end
end
