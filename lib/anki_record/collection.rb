# frozen_string_literal: true

require "pry"

require_relative "deck"
require_relative "helpers/collection_helper"
require_relative "helpers/time_helper"
require_relative "note_type"

module AnkiRecord
  ##
  # Collection represents the single record in the Anki database `col` table
  class Collection
    include AnkiRecord::CollectionHelper
    include AnkiRecord::TimeHelper
    def initialize
      setup_collection_instance_variables
    end

    private

      # rubocop:disable Metrics/MethodLength
      def setup_collection_instance_variables
        @id = 1
        @crt = nil
        @mod = milliseconds_since_epoch
        @scm = nil
        @ver = 11
        @dty = 0
        @usn = 0
        @ls = 0
        @conf = DEFAULT_CONFIGURATION_HASH
        @models = []
        @decks = []
        @dconf = {}
        @tags = []
      end
    # rubocop:enable Metrics/MethodLength
  end
end
