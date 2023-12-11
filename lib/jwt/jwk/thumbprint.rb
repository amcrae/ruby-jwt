# frozen_string_literal: true

module JWT
  module JWK
    # https://tools.ietf.org/html/rfc7638
    class Thumbprint
      attr_reader :jwk

      def initialize(jwk)
        @jwk = jwk
      end

      def generate
        urlsafe_encode64_nopad_SHA256(
          Digest::SHA256.digest(
            JWT::JSON.generate(
              jwk.members.sort.to_h
            )
          )
        )
      end

      alias to_s generate
      
      private

      # In the special case that the input is 256 bits long
      # the output without padding is always the padded version
      # with the final '=' removed.
      # This was the simplest way to work around the 'padding'
      # parameter not existing in the Ruby 2.2 std lib Base64.
      def urlsafe_encode64_nopad_SHA256(sha256bin)
        padded = ::Base64.urlsafe_encode64(
          sha256bin
        );
        if padded.length != 44 then
          raise ArgumentError.new("General data input not supported, must be 256bits.")
        end
        return padded[0...43]
      end

    end
  end
end
