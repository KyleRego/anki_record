# frozen_string_literal: true

require_relative "../support/note_type_spec_helpers"

RSpec.describe AnkiRecord::NoteType, "#add_note_field" do
  subject(:basic_note_type_from_existing) { described_class.new(collection: collection_argument, args: basic_model_hash) }

  include_context "note type helpers"

  let(:name_argument) { "test note type" }
  let(:collection_argument) do
    anki_package = AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection")
    anki_package.anki21_database.collection
  end

  it "raises an ArgumentError when passed an argument which is not a note field" do
    expect { basic_note_type_from_existing.add_note_field("not valid") }.to raise_error ArgumentError
  end
end
