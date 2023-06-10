# frozen_string_literal: true

module AnkiRecord
  # Module with the helper method to generate the note guid.
  module NoteGuidHelper
    private

    def globally_unique_id
      SecureRandom.base64(9).slice(1,10)
    end
  end
end
