# frozen_string_literal: true

RSpec.describe AnkiRecord::NoteField do
  subject(:field) { AnkiRecord::NoteField.new(note_type: note_type_argument, name: name_argument) }

  after { cleanup_test_files(directory: ".") }

  let(:name_argument) { "test field" }

  let(:collection_argument) do
    anki_database = AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection")
    AnkiRecord::Collection.new(anki_database: anki_database)
  end
  let(:note_type_argument) { AnkiRecord::NoteType.new(collection: collection_argument, name: "test note type for fields") }

  describe "::new" do
    context "with valid arguments (a parent note type and name)" do
      it "instantiates a field belonging to that note type" do
        expect(field.note_type).to eq note_type_argument
      end
      it "instantiates a field with the given name" do
        expect(field.name).to eq name_argument
      end
      it "instantiates a field with default font style 'Arial'" do
        expect(field.font_style).to eq "Arial"
      end
      it "instantiates a field with default font size 20" do
        expect(field.font_size).to eq 20
      end
      it "instantiates a field with sticky false" do
        expect(field.sticky).to eq false
      end
      it "instantiates a field with right to left false" do
        expect(field.right_to_left).to eq false
      end
      it "instantiates a field with an empty description" do
        expect(field.description).to eq ""
      end
      context "and it is the first field of the note type" do
        it "instantiates a field with ordinal number 0" do
          expect(field.ordinal_number).to eq 0
        end
      end
      context "and it is the second field of the note type" do
        before do
          note_type_argument.new_note_field(name: "the first note field")
        end
        it "instantiates a field with ordinal number 1" do
          expect(field.ordinal_number).to eq 1
        end
      end
    end
    context "with a name argument and an args argument" do
      it "throw an ArgumentError" do
        expect { AnkiRecord::NoteField.new(note_type: note_type_argument, name: "test", args: {}) }.to raise_error ArgumentError
      end
    end
  end

  describe "::from_existing" do
    subject(:note_field_from_existing) { AnkiRecord::NoteField.from_existing(note_type: note_type_argument, field_hash: field_hash) }

    context "when the field JSON object is the first field (with name 'Front') of the default Card 1 template for the default Basic note type" do
      let(:field_hash) do
        { "name" => "Front", "ord" => 0, "sticky" => false, "rtl" => false, "font" => "Arial", "size" => 20, "description" => "" }
      end
      it "instantiates a field for the argument note type" do
        expect(note_field_from_existing.note_type).to eq note_type_argument
      end
      it "instantiates a field with the name Front" do
        expect(note_field_from_existing.name).to eq "Front"
      end
      it "instantiates a field with ordinal number 0" do
        expect(note_field_from_existing.ordinal_number).to eq 0
      end
      it "instantiates a field with sticky: false" do
        expect(note_field_from_existing.sticky).to eq false
      end
      it "instantiates a field with right_to_left false" do
        expect(note_field_from_existing.right_to_left).to eq false
      end
      it "instantiates a field with editing font Arial" do
        expect(note_field_from_existing.font_style).to eq "Arial"
      end
      it "instantiates a field with editing font size 20" do
        expect(note_field_from_existing.font_size).to eq 20
      end
    end
  end
end
