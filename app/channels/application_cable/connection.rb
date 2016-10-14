module ApplicationCable
  class Connection < ActionCable::Connection::Base
    include SessionsHelper

    identified_by :user_id

    def connect
      self.user_id = find_verified_user
    end

    private
      def find_verified_user
        logged_in? ? current_user[:id] : reject_unauthorized_connection
      end
  end
end
