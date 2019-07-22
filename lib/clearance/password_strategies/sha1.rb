module Clearance
  module PasswordStrategies
    module SHA1
      require 'digest/sha1'

      extend ActiveSupport::Concern

      def authenticated?(password)
        encrypted_password == encrypt(password)
      end

      def password=(new_password)
        @password = new_password
        initialize_salt_if_necessary

        if new_password.present?
          self.encrypted_password = encrypt(new_password)
        end
      end

      private

      def encrypt(string)
        generate_hash "--#{salt}--#{string}--"
      end

      def generate_hash(string)
        if RUBY_VERSION >= '1.9'
          Digest::SHA1.hexdigest(string).encode 'UTF-8'
        else
          Digest::SHA1.hexdigest string
        end
      end

      def initialize_salt_if_necessary
        if salt.blank?
          self.salt = generate_random_code
        end
      end
    end
  end
end
