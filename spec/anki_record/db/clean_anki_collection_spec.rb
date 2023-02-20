# frozen_string_literal: true

RSpec.describe AnkiRecord do
  it "has the data insertion SQL statement to create the initial col record in db/clean_anki_collection.rb" do
    expect(AnkiRecord::CLEAN_COLLECTION_RECORD).not_to be nil
  end
end
