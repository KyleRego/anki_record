# frozen_string_literal: true

module AnkiRecord
  module DeckDefaults # :nodoc:
    private

      def default_deck_options_group_id
        anki21_database.deck_options_groups.min_by(&:id).id
      end

      def default_deck_today_array
        [0, 0].freeze
      end

      def default_collapsed
        false
      end
  end
end
