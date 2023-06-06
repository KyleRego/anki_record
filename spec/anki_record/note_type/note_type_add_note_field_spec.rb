# frozen_string_literal: true

require_relative "../support/clean_slate_anki_package"
require_relative "../support/note_type_hashes"

RSpec.describe AnkiRecord::NoteType, "#add_note_field" do
  subject(:basic_note_type_from_hash) { described_class.new(anki21_database:, args: basic_model_hash) }

  include_context "when the JSON of a note type from the col record is a Ruby hash"
  include_context "when the anki package is a clean slate"

  it "raises an ArgumentError when passed an argument which is not a note field" do
    expect { basic_note_type_from_hash.add_note_field("not valid") }.to raise_error ArgumentError
  end
end
