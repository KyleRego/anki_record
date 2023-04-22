# frozen_string_literal: true

require "./spec/anki_record/support/collection_spec_helpers"

RSpec.describe AnkiRecord::Collection, "#add_note_type" do
  include_context "collection shared helpers"

  it "throws an error if the argument object is not an instance of NoteType" do
    expect { collection.add_note_type("bad object") }.to raise_error ArgumentError
  end
end
