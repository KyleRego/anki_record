# frozen_string_literal: true

RSpec.describe AnkiRecord::NoteField do
  let(:name_argument) { "test field" }
  let(:note_type_argument) { AnkiRecord::NoteType.new(name: "test note type for fields") }
  subject(:field) { AnkiRecord::NoteField.new(note_type: note_type_argument, name: name_argument) }
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
  end
end
