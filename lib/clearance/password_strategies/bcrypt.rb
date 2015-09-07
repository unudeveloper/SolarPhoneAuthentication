module Clearance
  module PasswordStrategies
    # Uses BCrypt to authenticate users and store encrypted passwords.
    #
    # The BCrypt cost (the measure of how many key expansion iterations BCrypt
    # will perform) is automatically set to the minimum allowed value when
    # Rails is operating in the test environment and the default cost in all
    # other envionments. This provides a speed boost in tests.
    module BCrypt
      require 'bcrypt'

      def authenticated?(password)
        if encrypted_password.present?
          ::BCrypt::Password.new(encrypted_password) == password
        end
      end

      def password=(new_password)
        @password = new_password

        if new_password.present?
          self.encrypted_password = encrypt(new_password)
        end
      end

      private

      # @api private
      def encrypt(password)
        ::BCrypt::Password.create(password, cost: cost)
      end

      # @api private
      def cost
        if test_environment?
          ::BCrypt::Engine::MIN_COST
        else
          ::BCrypt::Engine::DEFAULT_COST
        end
      end

      # @api private
      def test_environment?
        defined?(::Rails) && ::Rails.env.test?
      end
    end
  end
end
