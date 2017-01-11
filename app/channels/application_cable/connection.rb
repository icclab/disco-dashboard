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
