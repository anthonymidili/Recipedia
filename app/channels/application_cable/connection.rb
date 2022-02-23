module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verfied_user
    end

  protected

    def find_verfied_user
      if verified_user = env['warden'].user
        verified_user
      else
        nil
        # reject_unauthorized_connection
      end
    end
  end
end
