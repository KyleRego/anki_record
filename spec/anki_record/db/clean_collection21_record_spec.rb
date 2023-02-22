# frozen_string_literal: true

RSpec.describe AnkiRecord do
  it "has the data insertion SQL statement to create the
      initial collection.anki21 col record in db/clean_collection21_record.rb" do
    expect(AnkiRecord::CLEAN_COLLECTION_21_RECORD).not_to be nil
  end
end
