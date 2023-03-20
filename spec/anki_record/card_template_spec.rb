# frozen_string_literal: true

RSpec.describe AnkiRecord::CardTemplate do
  subject(:template) { AnkiRecord::CardTemplate.new(note_type: note_type_argument, name: name_argument) }

  after { cleanup_test_files(directory: ".") }

  let(:collection_argument) do
    anki_package = AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection")
    AnkiRecord::Collection.new(anki_package: anki_package)
  end

  let(:note_type_argument) { AnkiRecord::NoteType.new(collection: collection_argument, name: "test note type for templates") }
  let(:name_argument) { "test template" }

  describe "::new used to instantiate a card template with a name argument" do
    context "with valid arguments (a parent note type and name)" do
      it "should instantiate a card template with note_type attribute equal to the note type argument" do
        expect(template.note_type).to eq note_type_argument
      end
      it "should instantiate a card template that is added to the note type's card_templates attribute" do
        expect(template.note_type.card_templates).to include template
      end
      it "should instantiate a card template with the given name" do
        expect(template.name).to eq name_argument
      end
      it "should instantiate a card template with an empty question format (an empty string)" do
        expect(template.question_format).to eq ""
      end
      it "should instantiate a card template with an empty answer format (an empty string)" do
        expect(template.answer_format).to eq ""
      end
      it "should instantiate a card template with an empty browser font style (an empty string)" do
        expect(template.browser_font_style).to eq ""
      end
      it "should instantiate a card template with a browser font size of 0" do
        expect(template.browser_font_size).to eq 0
      end
    end
    context "and the note type does not already have any card templates" do
      it "should instantiate a card template with ordinal number 0" do
        expect(template.ordinal_number).to eq 0
      end
    end
    context "and the note type already had one card template" do
      before { AnkiRecord::CardTemplate.new note_type: note_type_argument, name: "the first card template" }
      it "should instantiate a card template with ordinal number 1" do
        expect(template.ordinal_number).to eq 1
      end
    end
    context "with a name argument and an args argument" do
      it "should throw an ArgumentError" do
        expect { AnkiRecord::CardTemplate.new(note_type: note_type_argument, name: "test", args: {}) }.to raise_error ArgumentError
      end
    end
  end

  subject(:card_template_from_existing) { AnkiRecord::CardTemplate.new(note_type: note_type_argument, args: card_template_hash) }

  let(:card_template_hash) do
    { "name" => "Card 1",
      "ord" => 0,
      "qfmt" => "{{Front}}",
      "afmt" => "{{FrontSide}}\n\n<hr id=answer>\n\n{{Back}}",
      "bqfmt" => "",
      "bafmt" => "",
      "did" => nil,
      "bfont" => "",
      "bsize" => 0 }
  end

  describe "::new passed an args hash" do
    context "when the args hash is the default Card 1 template JSON object for the default Basic note type from a new Anki 2.1.54 profile" do
      it "should instantiate a card template with note_type attribute equal to the note type argument" do
        expect(card_template_from_existing.note_type).to eq note_type_argument
      end
      it "should instantiate a card template that is added to the note type's card_templates attribute" do
        expect(template.note_type.card_templates).to include template
      end
      it "should instantiate a card template with the name Card 1" do
        expect(card_template_from_existing.name).to eq "Card 1"
      end
      it "should instantiate a card template with ordinal number 0" do
        expect(card_template_from_existing.ordinal_number).to eq 0
      end
      it "should instantiate a card template with the data's question format" do
        expect(card_template_from_existing.question_format).to eq "{{Front}}"
      end
      it "should instantiate a card template with data's answer format" do
        expect(card_template_from_existing.answer_format).to eq "{{FrontSide}}\n\n<hr id=answer>\n\n{{Back}}"
      end
      it "should instantiate a template with an empty browser font style" do
        expect(template.browser_font_style).to eq ""
      end
      it "should instantiate a template with a browser font size of 0" do
        expect(template.browser_font_size).to eq 0
      end
    end
  end

  describe "#question_format=" do
    context "when the format specifies a field name that the card template's note type does not have a field for" do
      it "should throw an ArgumentError" do
        expect { card_template_from_existing.question_format = "{{unknown field}}" }.to raise_error ArgumentError
      end
    end
    context "when the format specifies two field names and the card template's note type has fields for both" do
      it "should set the question_format attribute to the argument" do
        AnkiRecord::NoteField.new note_type: note_type_argument, name: "Front"
        AnkiRecord::NoteField.new note_type: note_type_argument, name: "Back"
        card_template_from_existing.question_format = "{{Front}} and {{Back}}"
        expect(card_template_from_existing.question_format).to eq "{{Front}} and {{Back}}"
      end
    end
    context "when the format specifies a cloze field but the note type is not a cloze type" do
      it "should throw an ArgumentError" do
        AnkiRecord::NoteField.new note_type: note_type_argument, name: "Front"
        expect { card_template_from_existing.question_format = "{{cloze:Front}}" }.to raise_error ArgumentError
      end
    end
    context "when the format specifies a cloze field and the note type is not a cloze type" do
      it "should set the question_format attribute to the argument" do
        note_type_argument.cloze = true
        AnkiRecord::NoteField.new note_type: note_type_argument, name: "Front"
        card_template_from_existing.question_format = "{{cloze:Front}}"
        expect(card_template_from_existing.question_format).to eq "{{cloze:Front}}"
      end
    end
  end
  describe "#answer_format=" do
    context "when the format specifies a field name that the card template's note type does not have a field for" do
      it "should throw an ArgumentError" do
        expect { card_template_from_existing.answer_format = "{{unknown field}}" }.to raise_error ArgumentError
      end
    end
    context "when the format specifies two field names and the card template's note type has fields for both" do
      it "should set the answer_format attribute to the argument" do
        AnkiRecord::NoteField.new note_type: note_type_argument, name: "Front"
        AnkiRecord::NoteField.new note_type: note_type_argument, name: "Back"
        card_template_from_existing.answer_format = "{{Front}} and {{Back}}"
        expect(card_template_from_existing.answer_format).to eq "{{Front}} and {{Back}}"
      end
    end
    context "when the format specifies a cloze field but the note type is not a cloze type" do
      it "should throw an ArgumentError" do
        AnkiRecord::NoteField.new note_type: note_type_argument, name: "Front"
        expect { card_template_from_existing.answer_format = "{{cloze:Front}}" }.to raise_error ArgumentError
      end
    end
    context "when the format specifies a cloze field and the note type is not a cloze type" do
      it "should set the answer_format attribute to the argument" do
        note_type_argument.cloze = true
        AnkiRecord::NoteField.new note_type: note_type_argument, name: "Front"
        card_template_from_existing.answer_format = "{{cloze:Front}}"
        expect(card_template_from_existing.answer_format).to eq "{{cloze:Front}}"
      end
    end
  end
end
