# frozen_string_literal: true

RSpec.describe AnkiRecord::NoteField, "#new" do
  after { cleanup_test_files(directory: ".") }

  context "when passed a note type, name, and args arguments" do
    subject(:invalid_note_field_instantiation) do
      collection = AnkiRecord::AnkiPackage.new(name: "note_field_test_package").collection
      note_type = AnkiRecord::NoteType.new(collection: collection, name: "test note type for fields")
      described_class.new(note_type: note_type, name: "test", args: {})
    end

    it "throws an ArgumentError" do
      expect { invalid_note_field_instantiation }.to raise_error ArgumentError
    end
  end

  context "when passed a note type and name arguments" do
    subject(:field) { described_class.new(note_type: note_type, name: test_field_name) }

    let(:collection) { AnkiRecord::AnkiPackage.new(name: "note_field_test_package").collection }
    let(:note_type) { AnkiRecord::NoteType.new(collection: collection, name: "test note type for fields") }
    let(:test_field_name) { "test field" }

    note_field_integration_test_one = <<~DESC
      1. instantiates a field with note_type attribute equal to the note type argument
      2. instantiates a field which is added to the note type argument's note_fields attribute
      3. instantiates a field with the given name
      4. instantiates a field with font_style attribute being the default font style: 'Arial'
      5. instantiates a field with the font_size attribute being the default font size: 20
      6. instantiates a field with the sticky attribute being false
      7. instantiates a field with the right_to_left attribute being false
      8. instantiates a field with the description attribute being an empty string
      9. instantiates a field with the ordinal_number attribute being 0 because it is the note type's first field
    DESC

    # rubocop:disable RSpec/ExampleLength
    it(note_field_integration_test_one) do
      # 1
      expect(field.note_type).to eq note_type
      # 2
      expect(field.note_type.note_fields).to include field
      # 3
      expect(field.name).to eq test_field_name
      # 4
      expect(field.font_style).to eq "Arial"
      # 5
      expect(field.font_size).to eq 20
      # 6
      expect(field.sticky).to be false
      # 7
      expect(field.right_to_left).to be false
      # 8
      expect(field.description).to eq ""
      # 9
      expect(field.ordinal_number).to eq 0
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe "when the note type argument has a field already" do
    subject(:second_field) do
      collection = AnkiRecord::AnkiPackage.new(name: "note_field_test_package").collection
      note_type = AnkiRecord::NoteType.new(collection: collection, name: "test note type for fields")
      described_class.new(note_type: note_type, name: "first field")
      described_class.new(note_type: note_type, name: "second field")
    end

    it "instantiates a field with the ordinal_number attribute being 1" do
      expect(second_field.ordinal_number).to eq 1
    end
  end

  describe "when passed a note type and args (args being the Front field of the Card 1 template of the default Basic note type)" do
    subject(:note_field_from_existing) do
      front_field_args = { "name" => "Front", "ord" => 0, "sticky" => false,
                           "rtl" => false, "font" => "Arial", "size" => 20, "description" => "" }
      described_class.new(note_type: note_type, args: front_field_args)
    end

    let(:collection) { AnkiRecord::AnkiPackage.new(name: "note_field_test_package").collection }
    let(:note_type) { AnkiRecord::NoteType.new(collection: collection, name: "test note type for fields") }

    note_field_integration_test_two = <<~DESC
      1. instantiates a field with note_type attribute equal to the note type argument
      2. instantiates a note field that is added to the note_fields attribute of its note type
      3. instantiates a field with the name 'Front'
      4. instantiates a field with an empty string description
      5. instantiates a field with ordinal number 0
      6. instantiates a field with the sticky attribute being false
      7. instantiates a field with the right_to_left attribute being false
      8. instantiates a field with the font_style attribute being 'Arial'
      9. instantiates a field with the font_size attribute being 20
    DESC

    # rubocop:disable RSpec/ExampleLength
    it(note_field_integration_test_two) do
      # 1
      expect(note_field_from_existing.note_type).to eq note_type
      # 2
      expect(note_field_from_existing.note_type.note_fields).to include note_field_from_existing
      # 3
      expect(note_field_from_existing.name).to eq "Front"
      #  4
      expect(note_field_from_existing.description).to eq ""
      # 5
      expect(note_field_from_existing.ordinal_number).to eq 0
      #  6
      expect(note_field_from_existing.sticky).to be false
      #  7
      expect(note_field_from_existing.right_to_left).to be false
      #  8
      expect(note_field_from_existing.font_style).to eq "Arial"
      #  9
      expect(note_field_from_existing.font_size).to eq 20
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
