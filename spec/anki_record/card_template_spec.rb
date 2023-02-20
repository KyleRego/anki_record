# frozen_string_literal: true

RSpec.describe AnkiRecord::CardTemplate do
  subject(:template) { AnkiRecord::CardTemplate.new(note_type: note_type_argument, name: name_argument) }

  let(:note_type_argument) { AnkiRecord::NoteType.new(name: "test note type for templates") }
  let(:name_argument) { "test template" }

  describe "::new" do
    context "with valid arguments (a parent note type and name)" do
      it "instantiates a template belonging to that note type" do
        expect(template.note_type).to eq note_type_argument
      end
      it "instantiates a template with the given name" do
        expect(template.name).to eq name_argument
      end
    end
    context "and it is the first template of the note type" do
      it "instantiates a template with ordinal number 0" do
        expect(template.ordinal_number).to eq 0
      end
    end
    context "and it is the second template of the note type" do
      before { note_type_argument.new_card_template(name: "the first card template") }
      it "instantiates a template with ordinal number 1" do
        expect(template.ordinal_number).to eq 1
      end
    end
  end

  describe "#allowed_field_names" do
    context "when the template's note type has no fields" do
      it "should return an empty array" do
        expect(template.allowed_field_names).to eq []
      end
    end
    context "when the template's note type has one field" do
      let(:field_name) { "field 1 name" }
      before { note_type_argument.new_note_field(name: field_name) }
      it "should return an array with a length of 1" do
        expect(template.allowed_field_names.length).to eq 1
      end
      it "should return an array containing the name of the note type's field" do
        expect(template.allowed_field_names).to eq [field_name]
      end
    end
    context "when the template's note type has two fields" do
      let(:field_name1) { "field 1 name" }
      let(:field_name2) { "field 2 name" }
      before do
        note_type_argument.new_note_field(name: field_name1)
        note_type_argument.new_note_field(name: field_name2)
      end
      it "should return an array with a length of 2" do
        expect(template.allowed_field_names.length).to eq 2
      end
      it "should return an array containing the names of the note type's fields" do
        expect(template.allowed_field_names).to include field_name1, field_name2
      end
    end
  end
end
