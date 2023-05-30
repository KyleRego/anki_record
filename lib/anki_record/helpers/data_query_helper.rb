# frozen_string_literal: true

# TODO: Refactor to not have this module.
module AnkiRecord
  module Helpers
    # :nodoc:
    module DataQueryHelper
      def note_cards_data_for_note_id(sql_able:, id:)
        note_data = sql_able.prepare("select * from notes where id = ?").execute([id]).first
        return nil unless note_data

        cards_data = sql_able.prepare("select * from cards where nid = ?").execute([id]).to_a
        { note_data: note_data, cards_data: cards_data }
      end
    end
  end
end
