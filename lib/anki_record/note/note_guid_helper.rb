# frozen_string_literal: true

module AnkiRecord
  # Module with the helper method to generate the note guid.
  module NoteGuidHelper
    def globally_unique_id
      SecureRandom.uuid.slice(5...15)
    end
  end
end
