# frozen_string_literal: true

RSpec.describe AnkiRecord::NoteType do
  let(:name_argument) { "test note type" }
  subject(:note_type) do
    if defined?(cloze_argument)
      AnkiRecord::NoteType.new name: name_argument, cloze: cloze_argument
    else
      AnkiRecord::NoteType.new name: name_argument
    end
  end

  describe "::new" do
    context "with a name argument" do
      it "instantiates a note type with a name" do
        expect(note_type.name).to eq name_argument
      end
      it "instantiates a note type with an integer id using #milliseconds_since_epoch" do
        expect(note_type.id.class).to eq Integer
      end
      it "instantiates a non-cloze note type" do
        expect(note_type.cloze_type).to eq false
      end
      context "instantiates a note type with default CSS styling" do
        it "that defines styling for the 'card' CSS class" do
          expect(note_type.css).to include ".card {"
        end
        it "that includes .card: color: black;" do
          expect(note_type.css).to include "color: black;"
        end
        it "that includes .card: background-color: transparent;" do
          expect(note_type.css).to include "background-color: transparent;"
        end
        it "that includes .card: text-align: center;" do
          expect(note_type.css).to include "text-align: center;"
        end
      end
      context "and with a cloze: true argument" do
        let(:cloze_argument) { true }
        it "instantiates a cloze note type" do
          expect(note_type.cloze_type).to eq true
        end
      end
    end
    context "without a name argument" do
      let(:name_argument) { nil }
      it "throws an ArgumentError" do
        expect { subject }.to raise_error ArgumentError
      end
    end
  end

  let(:field_name_argument) { "test field name argument" }
  subject(:new_note_field) { note_type.new_note_field(name: field_name_argument) }

  describe "#new_note_field with a string name argument" do
    it "should increase the number of fields this note type has by 1" do
      expect { new_note_field }.to change { note_type.fields.count }.from(0).to(1)
    end
    it "should add an object of type AnkiRecord::NoteField to this note type's fields attribute" do
      new_note_field
      expect(note_type.fields.first.instance_of?(AnkiRecord::NoteField)).to eq true
    end
  end

  let(:template_name_argument) { "test template name argument" }
  subject(:new_card_template) { note_type.new_card_template(name: template_name_argument) }

  describe "#new_card_template with a string name argument" do
    it "should increase the number of templates this note type has by 1" do
      expect { new_card_template }.to change { note_type.templates.count }.from(0).to(1)
    end
    it "should add an object of type AnkiRecord::NoteField to this note type's fields attribute" do
      new_card_template
      expect(note_type.templates.first.instance_of?(AnkiRecord::CardTemplate)).to eq true
    end
  end
end
