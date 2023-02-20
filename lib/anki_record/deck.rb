# frozen_string_literal: true

require "pry"

require_relative "helpers/shared_constants_helper"
require_relative "helpers/time_helper"

module AnkiRecord
  ##
  # Deck represents an Anki deck
  class Deck
    include SharedConstantsHelper
    include TimeHelper

    DEFAULT_DECK_TODAY_ARRAY = [0, 0].freeze
    DEFAULT_COLLAPSED = false

    private_constant :DEFAULT_DECK_TODAY_ARRAY, :DEFAULT_COLLAPSED

    def initialize(name:)
      setup_deck_instance_variables(name: name)
    end

    ##
    # TODO: Instantiates a note type from an existing json object in the col.decks column
    def self.from_existing(deck_hash:)
      deck_hash["name"]
    end

    private

      # rubocop:disable Metrics/MethodLength
      def setup_deck_instance_variables(name:)
        @id = milliseconds_since_epoch
        @last_modified_time = seconds_since_epoch
        @name = name
        @usn = NEW_OBJECT_USN
        @learn_today = @review_today = @new_today = @time_today = DEFAULT_DECK_TODAY_ARRAY
        @collapsed_in_main_window = DEFAULT_COLLAPSED
        @collapsed_in_browser = DEFAULT_COLLAPSED
        @description = ""
        @dyn = NON_FILTERED_DECK_DYN
        @deck_options_group_id = nil # TODO
        @extend_new = 0
        @extend_review = 0
      end
    # rubocop:enable Metrics/MethodLength
  end
end
