# frozen_string_literal: true

RSpec.describe AnkiRecord::Collection do
  subject(:collection) { AnkiRecord::Collection.new(anki_database: anki_database) }
  # Be aware that AnkiPackage has a Collection as a collaborator upon instantiation
  let(:anki_database) { AnkiRecord::AnkiPackage.new(name: "package_to_test_collection") }

  after { cleanup_test_files(directory: ".") }

  describe "::new" do
    it "instantiates a new Collection object" do
      expect(collection.instance_of?(AnkiRecord::Collection)).to eq true
    end
  end
end
