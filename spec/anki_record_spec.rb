# frozen_string_literal: true

RSpec.describe AnkiRecord do
  it "is being developed" do
    expect(true).to eq true
  end

  context "end to end tests" do
    it "should generate a new, empty Anki package (test1.apkg) that should import into Anki correctly" do
      db = AnkiRecord::AnkiPackage.new name: "test1"
      db.zip_and_close
    end
  end
end
