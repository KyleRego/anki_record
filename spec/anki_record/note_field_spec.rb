# frozen_string_literal: true

RSpec.describe AnkiRecord::NoteField do
  after { cleanup_test_files(directory: ".") }

  describe "::new" do
    context "when passed a note type argument, and both name and args arguments" do
      subject(:invalid_note_field_instantiation) do
        collection = AnkiRecord::AnkiPackage.new(name: "note_field_test_package").collection
        note_type = AnkiRecord::NoteType.new(collection: collection, name: "test note type for fields")
        AnkiRecord::NoteField.new(note_type: note_type, name: "test", args: {})
      end
      it "should throw an ArgumentError" do
        expect { invalid_note_field_instantiation }.to raise_error ArgumentError
      end
    end
  end

  describe "::new when passed note_type and name arguments" do
    before(:all) do
      collection = AnkiRecord::AnkiPackage.new(name: "note_field_test_package").collection
      @note_type = AnkiRecord::NoteType.new(collection: collection, name: "test note type for fields")
      @name = "test field"
      @field = AnkiRecord::NoteField.new(note_type: @note_type, name: @name)
    end
    it "should instantiate a field with note_type attribute equal to the note type argument" do
      expect(@field.note_type).to eq @note_type
    end
    it "should instantiate a field which is added to the note type argument's note_fields attribute" do
      expect(@field.note_type.note_fields).to include @field
    end
    it "should instantiate a field with the given name" do
      expect(@field.name).to eq @name
    end
    it "should instantiate a field with font_style attribute being the default font style: 'Arial'" do
      expect(@field.font_style).to eq "Arial"
    end
    it "should instantiate a field with the font_size attribute being the default font size: 20" do
      expect(@field.font_size).to eq 20
    end
    it "should instantiate a field with the sticky attribute being false" do
      expect(@field.sticky).to eq false
    end
    it "should instantiate a field with the right_to_left attribute being false" do
      expect(@field.right_to_left).to eq false
    end
    it "should instantiate a field with the description attribute being an empty string" do
      expect(@field.description).to eq ""
    end
    context "and the note type it is being added to has no fields already" do
      it "should instantiate a field with the ordinal_number attribute being 0" do
        expect(@field.ordinal_number).to eq 0
      end
    end
  end

  describe "::new when passed note_type and name arguments and the note type argument has a field already" do
    subject(:second_field) do
      collection = AnkiRecord::AnkiPackage.new(name: "note_field_test_package").collection
      note_type = AnkiRecord::NoteType.new(collection: collection, name: "test note type for fields")
      AnkiRecord::NoteField.new(note_type: note_type, name: "first field")
      AnkiRecord::NoteField.new(note_type: note_type, name: "second field")
    end
    it "should instantiate a field with the ordinal_number attribute being 1" do
      expect(second_field.ordinal_number).to eq 1
    end
  end

  describe "::new when passed note_type and args arguments (args being the Front field of the Card 1 template of the default Basic note type)" do
    before(:all) do
      front_field_args = { "name" => "Front", "ord" => 0, "sticky" => false, "rtl" => false, "font" => "Arial", "size" => 20, "description" => "" }
      collection = AnkiRecord::AnkiPackage.new(name: "note_field_test_package").collection
      @note_type = AnkiRecord::NoteType.new(collection: collection, name: "test note type for fields")
      @note_field_from_existing = AnkiRecord::NoteField.new(note_type: @note_type, args: front_field_args)
    end
    it "should instantiate a field with note_type attribute equal to the note type argument" do
      expect(@note_field_from_existing.note_type).to eq @note_type
    end
    it "should instantiate a note field that is added to the note_fields attribute of its note type" do
      expect(@note_field_from_existing.note_type.note_fields).to include @note_field_from_existing
    end
    it "should instantiate a field with the name 'Front'" do
      expect(@note_field_from_existing.name).to eq "Front"
    end
    it "should instantiate a field with an empty string description" do
      expect(@note_field_from_existing.description).to eq ""
    end
    it "should instantiate a field with ordinal number 0" do
      expect(@note_field_from_existing.ordinal_number).to eq 0
    end
    it "should instantiate a field with the sticky attribute being false" do
      expect(@note_field_from_existing.sticky).to eq false
    end
    it "should instantiate a field with the right_to_left attribute being false" do
      expect(@note_field_from_existing.right_to_left).to eq false
    end
    it "should instantiate a field with the font_style attribute being 'Arial'" do
      expect(@note_field_from_existing.font_style).to eq "Arial"
    end
    it "should instantiate a field with the font_size attribute being 20" do
      expect(@note_field_from_existing.font_size).to eq 20
    end
  end
end
