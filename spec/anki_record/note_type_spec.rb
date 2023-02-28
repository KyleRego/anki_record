# frozen_string_literal: true

RSpec.describe AnkiRecord::NoteType do
  subject(:note_type) do
    if defined?(cloze_argument)
      AnkiRecord::NoteType.new collection: collection_argument, name: name_argument, cloze: cloze_argument
    else
      AnkiRecord::NoteType.new collection: collection_argument, name: name_argument
    end
  end

  after { cleanup_test_files(directory: ".") }

  let(:name_argument) { "test note type" }
  let(:collection_argument) do
    anki_package = AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection")
    AnkiRecord::Collection.new(anki_package: anki_package)
  end

  describe "::new with name argument" do
    it "should instantiate a note type belonging to the collection argument" do
      expect(note_type.collection).to eq collection_argument
    end
    it "should instantiate a note type with an integer id" do
      expect(note_type.id.class).to eq Integer
    end
    it "should instantiate a note type with name attribute equal to the name argument" do
      expect(note_type.name).to eq name_argument
    end
    it "should instantiate a non-cloze note type (a note type with the cloze attribute being false)" do
      expect(note_type.cloze).to eq false
    end
    it "should instantiate a note type with the card_templates attribute being an empty array" do
      expect(note_type.card_templates).to eq []
    end
    it "should instantiate a note type with the fields attribute being an empty array" do
      expect(note_type.fields).to eq []
    end
    it "should instantiate a note type with a deck_id attribute of nil" do
      expect(note_type.deck_id).to eq nil
    end
    it "should instantiate a note type with the tags attribute being an empty array" do
      expect(note_type.tags).to eq []
    end
    context "should instantiate a note type with default CSS styling" do
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
      it "should instantiate a cloze note type (a note type with the cloze attribute being true)" do
        expect(note_type.cloze).to eq true
      end
    end
    context "without a name argument" do
      let(:name_argument) { nil }
      it "should throw an ArgumentError" do
        expect { note_type }.to raise_error ArgumentError
      end
    end
    context "and an args argument" do
      it "should throw an ArgumentError" do
        expect { AnkiRecord::NoteType.new(collection: collection_argument, name: "test", args: {}) }.to raise_error ArgumentError
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
    it "should increase the number of card templates this note type has by 1" do
      expect { new_card_template }.to change { note_type.card_templates.count }.from(0).to(1)
    end
    it "should add an object of type AnkiRecord::NoteField to this note type's fields attribute" do
      new_card_template
      expect(note_type.card_templates.first.instance_of?(AnkiRecord::CardTemplate)).to eq true
    end
  end

  subject(:note_type_from_existing) { AnkiRecord::NoteType.new(collection: collection_argument, args: model_hash) }

  describe "::new passed an args hash" do
    context "when the model_hash argument is the default JSON object for the Basic note type exported from a fresh Anki 2.1.54 profile" do
      # rubocop:disable Layout/LineContinuationLeadingSpace
      let(:model_hash) do
        { "id" => 1_676_902_364_661,
          "name" => "Basic",
          "type" => 0,
          "mod" => 0,
          "usn" => 0,
          "sortf" => 0,
          "did" => nil,
          "tmpls" =>
          [{ "name" => "Card 1",
             "ord" => 0,
             "qfmt" => "{{Front}}",
             "afmt" => "{{FrontSide}}\n\n<hr id=answer>\n\n{{Back}}",
             "bqfmt" => "",
             "bafmt" => "",
             "did" => nil,
             "bfont" => "",
             "bsize" => 0 }],
          "flds" =>
          [{ "name" => "Front", "ord" => 0, "sticky" => false, "rtl" => false, "font" => "Arial", "size" => 20, "description" => "" },
           { "name" => "Back", "ord" => 1, "sticky" => false, "rtl" => false, "font" => "Arial", "size" => 20, "description" => "" }],
          "css" =>
          ".card {\n" \
          "    font-family: arial;\n" \
          "    font-size: 20px;\n" \
          "    text-align: center;\n" \
          "    color: black;\n" \
          "    background-color: white;\n" \
          "}\n",
          "latexPre" =>
          "\\documentclass[12pt]{article}\n" \
          "\\special{papersize=3in,5in}\n" \
          "\\usepackage[utf8]{inputenc}\n" \
          "\\usepackage{amssymb,amsmath}\n" \
          "\\pagestyle{empty}\n" \
          "\\setlength{\\parindent}{0in}\n" \
          "\\begin{document}\n",
          "latexPost" => "\\end{document}",
          "latexsvg" => false,
          "req" => [[0, "any", [0]]] }
      end
      # rubocop:enable Layout/LineContinuationLeadingSpace

      it "should instantiate a note type belonging to the collection argument" do
        expect(note_type.collection).to eq collection_argument
      end
      it "should instantiate a note type object with id the same as the data" do
        expect(note_type_from_existing.id).to eq model_hash["id"]
      end
      it "should instantiate a note type object with the same name as the data ('Basic')" do
        expect(note_type_from_existing.name).to eq "Basic"
      end
      it "should instantiate a non-cloze note type" do
        expect(note_type_from_existing.cloze).to eq false
      end
      it "should instantiate a note type with the same id as the data" do
        expect(note_type_from_existing.id).to eq 1_676_902_364_661
      end
      it "should instantiates a note type with the same deck id as the data (NULL or nil)" do
        expect(note_type_from_existing.deck_id).to eq nil
      end
      it "should instantiate a note type with one card template" do
        expect(note_type_from_existing.card_templates.count).to eq 1
      end
      it "should instantiate a note type with a template with the name Card 1" do
        expect(note_type_from_existing.card_templates.first.name).to eq "Card 1"
      end
      it "should instantiate a note type with 2 fields" do
        expect(note_type_from_existing.fields.count).to eq 2
      end
      it "should instantiate a note type with a 'Front' field and a 'Back' field" do
        expect(note_type_from_existing.fields.map(&:name).sort).to eq %w[Back Front]
      end
      it "should instantiate a note type with the CSS styling from the data" do
        expect(note_type_from_existing.css).to eq model_hash["css"]
      end
      it "should instantiate a note type with the data's LaTeX preamble" do
        expect(note_type_from_existing.latex_preamble).to eq model_hash["latexPre"]
      end
      it "should instantiate a note type with the data's LaTeX postamble" do
        expect(note_type_from_existing.latex_postamble).to eq model_hash["latexPost"]
      end
      it "should instantiate a note type with latex_svg false" do
        expect(note_type_from_existing.latex_svg).to eq false
      end
      it "should instantiate a note type with nil tags attribute because it is missing from the data" do
        expect(note_type_from_existing.tags).to eq nil
      end
    end
  end
end
