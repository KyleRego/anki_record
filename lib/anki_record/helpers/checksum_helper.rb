# frozen_string_literal: true

require "digest"

module AnkiRecord
  ##
  # A module for the method that calculates the checksum value of notes.
  #
  # This checksum is used by Anki to detect duplicates.
  module ChecksumHelper
    ##
    # Compute the integer representation of the first 8 characters of the digest
    # (calculated using the SHA-1 Secure Hash Algorithm) of the argument
    # TODO: This needs to be expanded to strip HTML (except media)
    # and more tests to ensure it calculates the same value as Anki does in that case
    def checksum(sfld)
      Digest::SHA1.hexdigest(sfld)[0...8].to_i(16).to_s
    end
  end
end
