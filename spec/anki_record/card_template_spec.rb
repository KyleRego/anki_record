# frozen_string_literal: true

RSpec.describe AnkiRecord::CardTemplate do
  subject(:template) { AnkiRecord::CardTemplate.new(note_type: note_type_argument, name: name_argument) }

  after { cleanup_test_files(directory: ".") }

  let(:collection_argument) do
    # TODO: since this exact helper is used in many spec files, extract it to a shared one
    # TODO: in future, certain (most) tests should use a double of this to decrease the test suite run time
    anki_package = AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection")
    AnkiRecord::Collection.new(anki_package: anki_package)
  end

  let(:note_type_argument) { AnkiRecord::NoteType.new(collection: collection_argument, name: "test note type for templates") }
  let(:name_argument) { "test template" }

  describe "::new used to instantiate a card template with a name argument" do
    context "with valid arguments (a parent note type and name)" do
      it "instantiates a template belonging to that note type" do
        expect(template.note_type).to eq note_type_argument
      end
      it "instantiates a template with the given name" do
        expect(template.name).to eq name_argument
      end
      it "instantiates a template with an empty question format" do
        expect(template.question_format).to eq ""
      end
      it "instantiates a template with an empty answer format" do
        expect(template.answer_format).to eq ""
      end
      it "instantiates a template with an empty browser font style" do
        expect(template.browser_font_style).to eq ""
      end
      it "instantiates a template with a browser font size of 0" do
        expect(template.browser_font_size).to eq 0
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
    context "with a name argument and an args argument" do
      it "throw an ArgumentError" do
        expect { AnkiRecord::CardTemplate.new(note_type: note_type_argument, name: "test", args: {}) }.to raise_error ArgumentError
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

  describe "::new passed an args hash" do
    subject(:card_template_from_existing) { AnkiRecord::CardTemplate.new(note_type: note_type_argument, args: card_template_hash) }

    context "when the args hash is the default Card 1 template JSON object for the default Basic note type from a new Anki 2.1.54 profile" do
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
      it "instantiates a card template for the argument note type" do
        expect(card_template_from_existing.note_type).to eq note_type_argument
      end
      it "instantiates a card template with the name Card 1" do
        expect(card_template_from_existing.name).to eq "Card 1"
      end
      it "instantiates a card template with ordinal number 0" do
        expect(card_template_from_existing.ordinal_number).to eq 0
      end
      it "instantiates a card template with the data's question format" do
        expect(card_template_from_existing.question_format).to eq "{{Front}}"
      end
      it "instantiates a card template with data's answer format" do
        expect(card_template_from_existing.answer_format).to eq "{{FrontSide}}\n\n<hr id=answer>\n\n{{Back}}"
      end
      it "instantiates a template with an empty browser font style" do
        expect(template.browser_font_style).to eq ""
      end
      it "instantiates a template with a browser font size of 0" do
        expect(template.browser_font_size).to eq 0
      end
    end
  end
end
