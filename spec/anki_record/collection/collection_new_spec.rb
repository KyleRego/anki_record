# frozen_string_literal: true

require "./spec/anki_record/support/clean_slate_anki_package"

RSpec.describe AnkiRecord::Collection, "#new" do
  include_context "when the anki package is a clean slate"

  it "instantiates a collection with defaults: 1 deck, 1 deck options group, and 5 note types" do
    expect(collection).to be_a described_class
    expect(collection.anki21_database).to be_a(AnkiRecord::Anki21Database)
    expect(collection.id).to eq 1
    expect(collection.created_at_timestamp).to be_a Integer
    expect(collection.last_modified_timestamp).to eq 0
  end
end
