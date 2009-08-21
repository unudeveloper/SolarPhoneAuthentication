module Clearance
  module Authentication

    def self.included(controller) # :nodoc:
      controller.send(:include, InstanceMethods)

      controller.class_eval do
        helper_method :current_user, :signed_in?, :signed_out?
        hide_action   :current_user, :signed_in?, :signed_out?
      end
    end

    module InstanceMethods
      # User in the current cookie
      #
      # @return [User, nil]
      def current_user
        @_current_user ||= user_from_cookie
      end

      # Is the current user signed in?
      #
      # @return [true, false]
      def signed_in?
        ! current_user.nil?
      end

      # Is the current user signed out?
      #
      # @return [true, false]
      def signed_out?
        current_user.nil?
      end

      # Deny the user access if they are signed out.
      #
      # @example
      #   before_filter :authenticate
      def authenticate
        deny_access unless signed_in?
      end

      # Sign user in to cookie.
      #
      # @param [User]
      #
      # @example
      #   sign_in(@user)
      def sign_in(user)
        if user
          user.remember_me!
          cookies[:remember_token] = { :value   => user.token,
                                       :expires => user.token_expires_at }
        end
      end

      # Sign user out of cookie.
      #
      # @param [User]
      #
      # @example
      #   sign_out(@user)
      def sign_out(user)
        user.forget_me! if user
        cookies.delete(:remember_token)
        reset_session
      end

      # Store the current location.
      # Display a flash message if included.
      # Redirect to sign in.
      #
      # @param [String] optional flash message to display to denied user
      def deny_access(flash_message = nil)
        store_location
        flash[:failure] = flash_message if flash_message
        redirect_to(new_session_url)
      end

      protected

      def user_from_cookie
        if token = cookies[:remember_token]
          return nil  unless user = ::User.find_by_token(token)
          return user if     user.remember?
        end
      end

      def sign_user_in(user)
        warn "[DEPRECATION] sign_user_in: unnecessary. use sign_in(user) instead."
        sign_in(user)
      end

      def store_location
        session[:return_to] = request.request_uri if request.get?
      end

      def redirect_back_or(default)
        redirect_to(return_to || default)
        clear_return_to
      end

      def return_to
        session[:return_to] || params[:return_to]
      end

      def clear_return_to
        session[:return_to] = nil
      end

      def redirect_to_root
        redirect_to(root_url)
      end
    end

  end
end
