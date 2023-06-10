# frozen_string_literal: true

require "digest"

module AnkiRecord
  module Helpers
    ##
    # A module for the method that computes the guid value of notes.
    #
    # This guid is used by Anki when importing a deck package to update existing notes
    # rather than create duplicates of them.
    module AnkiGuidHelper
      ##
      # Returns a random string of 10 characters sliced out of a random base64 string (RFC 3548).
      def self.globally_unique_id
        SecureRandom.base64(9).slice(1, 10)
      end
    end
  end
end
