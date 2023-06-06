# frozen_string_literal: true

require_relative "../support/clean_slate_anki_package"

RSpec.describe AnkiRecord::NoteField, "#new" do
  include_context "when the anki package is a clean slate"

  it "throws an error when passed note_type, name, and args arguments" do
    expect do
      note_type = AnkiRecord::NoteType.new(anki21_database:, name: "test note type for fields")
      described_class.new(note_type:, name: "test", args: {})
    end.to raise_error ArgumentError
  end

  context "when passed a note type and name arguments" do
    subject(:field) { described_class.new(note_type:, name: test_field_name) }

    let(:note_type) { AnkiRecord::NoteType.new(anki21_database:, name: "test note type for fields") }
    let(:test_field_name) { "test field" }

    # rubocop:disable RSpec/ExampleLength
    it "instantiates a note field" do
      expect(field.note_type).to eq note_type
      expect(field.note_type.note_fields).to include field
      expect(field.name).to eq test_field_name
      expect(field.font_style).to eq "Arial"
      expect(field.font_size).to eq 20
      expect(field.sticky).to be false
      expect(field.right_to_left).to be false
      expect(field.description).to eq ""
      expect(field.ordinal_number).to eq 0
    end
    # rubocop:enable RSpec/ExampleLength
  end

  context "when the note type argument has a field already" do
    subject(:second_field) do
      note_type = AnkiRecord::NoteType.new(anki21_database:, name: "test note type for fields")
      described_class.new(note_type:, name: "first field")
      described_class.new(note_type:, name: "second field")
    end

    it "instantiates a note field with the ordinal_number attribute being 1" do
      expect(second_field.ordinal_number).to eq 1
    end
  end

  context "when passed a note type and args (args being the Front field of the Card 1 template of the default Basic note type)" do
    subject(:note_field_from_existing) do
      front_field_args = { "name" => "Front", "ord" => 0, "sticky" => false,
                           "rtl" => false, "font" => "Arial", "size" => 20, "description" => "" }
      described_class.new(note_type:, args: front_field_args)
    end

    let(:note_type) { AnkiRecord::NoteType.new(anki21_database:, name: "test note type for fields") }

    # rubocop:disable RSpec/ExampleLength
    it "instantiates a note field from the raw data" do
      expect(note_field_from_existing.note_type).to eq note_type
      expect(note_field_from_existing.note_type.note_fields).to include note_field_from_existing
      expect(note_field_from_existing.name).to eq "Front"
      expect(note_field_from_existing.description).to eq ""
      expect(note_field_from_existing.ordinal_number).to eq 0
      expect(note_field_from_existing.sticky).to be false
      expect(note_field_from_existing.right_to_left).to be false
      expect(note_field_from_existing.font_style).to eq "Arial"
      expect(note_field_from_existing.font_size).to eq 20
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
