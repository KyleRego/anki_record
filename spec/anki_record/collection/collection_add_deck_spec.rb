# frozen_string_literal: true

require "./spec/anki_record/support/collection_spec_helpers"

RSpec.describe AnkiRecord::Collection, "#add_deck" do
  include_context "collection shared helpers"

  it "throws an error if the argument object is not an instance of Deck" do
    expect { collection.add_deck("bad object") }.to raise_error ArgumentError
  end
end
