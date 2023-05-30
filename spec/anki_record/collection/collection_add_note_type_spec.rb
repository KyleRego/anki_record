# frozen_string_literal: true

require "./spec/anki_record/support/clean_slate_anki_package"

RSpec.describe AnkiRecord::Collection, "#add_note_type" do
  include_context "when the anki package is a clean slate"

  it "throws an error if the argument object is not an instance of NoteType" do
    expect { collection.add_note_type("bad object") }.to raise_error ArgumentError
  end
end
