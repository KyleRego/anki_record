# frozen_string_literal: true

module AnkiRecord
  # Helper module for methods that can be used with the +sql_able+ duck type.
  module DataQueryHelper
    def note_cards_data_for_note_id(sql_able:, id:) # :nodoc:
      note_data = sql_able.prepare("select * from notes where id = ?").execute([id]).first
      return nil unless note_data

      cards_data = sql_able.prepare("select * from cards where nid = ?").execute([id]).to_a
      { note_data: note_data, cards_data: cards_data }
    end
  end
end
