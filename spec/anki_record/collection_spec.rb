# frozen_string_literal: true

RSpec.describe AnkiRecord::Collection do
  subject(:collection) { AnkiRecord::Collection.new(anki_database: anki_database) }
  # Be aware that AnkiPackage has a Collection as a collaborator upon instantiation

  after { cleanup_test_files(directory: ".") }

  context "when the *.apkg file is a new empty *.apkg created using this library" do
    let(:anki_database) { AnkiRecord::AnkiPackage.new(name: "package_to_test_collection") }

    describe "::new" do
      it "instantiates a new Collection object" do
        expect(collection.instance_of?(AnkiRecord::Collection)).to eq true
      end
      # These specs may need to change if it is problematic to make new packages with all the default note
      # types of a new Anki installation; this could cause issues creating extra note types that
      # people do not want in the import even if they are unused by any notes.
      it "instantiates a new Collection object with the 5 default note types" do
        expect(collection.note_types.count).to eq 5
      end
      it "instantiates a new Collection object with note_types that are instances of NoteType" do
        expect(collection.note_types.all? { |nt| nt.instance_of?(AnkiRecord::NoteType) }).to eq true
      end
      it "instantiates a new Collection object with the 1 default deck" do
        expect(collection.decks.count).to eq 1
      end
      it "instantiates a new Collection object with decks that are instances of Deck" do
        expect(collection.decks.first.instance_of?(AnkiRecord::Deck)).to eq true
      end
      # TODO: specs for deck option groups that are created
    end
  end
end
