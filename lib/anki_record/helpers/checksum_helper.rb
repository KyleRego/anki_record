# frozen_string_literal: true

require "digest"

module AnkiRecord
  ##
  # A module for the method that calculates the checksum value of notes.
  #
  # This checksum is used by Anki to detect duplicates.
  module ChecksumHelper
    ##
    # Returns the integer representation of the first 8 characters of the SHA-1 digest of the +sfld+ argument
    def checksum(sfld)
      Digest::SHA1.hexdigest(sfld)[0...8].to_i(16).to_s
    end
  end
end
