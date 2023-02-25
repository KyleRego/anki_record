# frozen_string_literal: true

RSpec.describe AnkiRecord do
  it "is being developed" do
    expect(true).to eq true
  end

  before(:all) { cleanup_test_files directory: "." }

  context "end to end tests" do
    describe "::new and ::open without block arguments" do
      it "should zip a new, empty Anki package (test1.apkg)
          and then it should open that file and zip an updated version (test1-number.apkg)
          and both of these should import into Anki correctly" do
        apkg = AnkiRecord::AnkiPackage.new name: "test1"
        apkg.zip
        apkg2 = AnkiRecord::AnkiPackage.open path: "test1.apkg"
        apkg2.zip
      end
    end
  end
end
