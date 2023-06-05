# frozen_string_literal: true

require "./spec/anki_record/support/clean_slate_anki_package"

RSpec.describe AnkiRecord::Anki21Database, "#def_delegators" do
  include_context "when the anki package is a clean slate"

  it { expect(anki21_database).to respond_to(:find_deck_by) }

  it { expect(anki21_database).to respond_to(:find_deck_options_group_by) }

  it { expect(anki21_database).to respond_to(:find_note_type_by) }
end
