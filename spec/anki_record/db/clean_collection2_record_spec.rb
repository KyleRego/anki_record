# frozen_string_literal: true

RSpec.describe AnkiRecord do
  it "has the data insertion SQL statement to create the
      initial collection.anki2 col record in db/clean_collection2_record.rb" do
    expect(AnkiRecord::CLEAN_COLLECTION_2_RECORD).not_to be nil
  end
end
