# frozen_string_literal: true

if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'
  class Java::OrgJrubyExtOpenssl::PKeyEC
    field_accessor :curveName
  end

  # Make the paramSpec private field available to ruby from the Java class
  class Java::OrgJrubyExtOpenssl::PKeyEC::Group
    field_accessor :paramSpec, :curve_name, :key
  end

  class OpenSSL::PKey::EC::Group
    # Save the original curve_name implementation
    alias_method :old_curve_name, :curve_name

    # Override the curve_name implementation to catch try an alternative
    # means of retreiving the curve name when the private field is null
    # Basically, just get it from the curve parameters if it is a named curve.
    def curve_name
      old_curve_name
    rescue java.lang.NullPointerException
      # Get access to the internal fields
      internal_group = self.to_java
      if internal_group.paramSpec.kind_of?(Java::OrgBouncycastleJceSpec::ECNamedCurveSpec)
        name = internal_group.paramSpec.name
        internal_group.curve_name = name
        internal_group.key.to_java(org.jruby.ext.openssl.PKeyEC).curveName = name
        return name
      end
      nil
    end
  end

  class OpenSSL::PKey::EC
    # Support generation as a class method (may not be perfectly equivalent)
    def self.generate(ec_group)
      key = self.new(ec_group)
      key.generate_key
      key
    end
  end

  module JWT

    def self.openssl_3_hmac_empty_key_regression?
      # assuming Bouncy Castle does not have this regression.
      false
    end

    module Algos
      module Ecdsa
        module_function

        def verify(algorithm, public_key, signing_input, signature)
          curve_definition = curve_by_name(public_key.group.curve_name)
          key_algorithm = curve_definition[:algorithm]
          if algorithm != key_algorithm
            raise IncorrectAlgorithm, "payload algorithm is #{algorithm} but #{key_algorithm} verification key was provided"
          end

          digest = OpenSSL::Digest.new(curve_definition[:digest])
          # JRuby OpenSSL does not implement dsa_verify_asn1 and difficult to just
          # add it as an extension method as the PKey.verify takes args that would be lost.
          #public_key.dsa_verify_asn1(digest.digest(signing_input), raw_to_asn1(signature, public_key))
          sig_asn1 = raw_to_asn1(signature, public_key)
          public_key.verify(digest, sig_asn1, signing_input)
        rescue OpenSSL::PKey::PKeyError => e
          raise JWT::VerificationError, e.message
        end
      end
    end
  end
end
