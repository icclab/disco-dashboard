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

# Establishes Cable connection with authorized client for ActionCable support.
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    # Includes SessionHelper to be able to access to the session methods
    include SessionsHelper

    identified_by :user_id

    # Method that establishes connection with authorized user client
    def connect
      self.user_id = find_verified_user
    end

    private
      # Method that checks whether connected client authorized or not
      def find_verified_user
        logged_in? ? current_user[:id] : reject_unauthorized_connection
      end
  end
end
