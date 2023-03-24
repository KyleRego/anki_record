# frozen_string_literal: true

RSpec.describe AnkiRecord::NoteType do
  after { cleanup_test_files(directory: ".") }
  # rubocop:disable Layout/LineContinuationLeadingSpace
  # rubocop:disable Metrics/MethodLength
  ##
  # Returns the Ruby hash representing the default Basic note type args
  def basic_model_hash
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

  ##
  # Returns the Ruby hash representing the default Basic and Reversed Card note type args
  def basic_and_reversed_card_model_hash
    { "id" => 1_676_902_364_662,
      "name" => "Basic (and reversed card)",
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
       "bsize" => 0 },
     { "name" => "Card 2",
       "ord" => 1,
       "qfmt" => "{{Back}}",
       "afmt" => "{{FrontSide}}\n\n<hr id=answer>\n\n{{Front}}",
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
      "req" => [[0, "any", [0]], [1, "any", [1]]] }
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Layout/LineContinuationLeadingSpace

  describe "::new when passed a name argument" do
    before(:all) do
      @anki_package = AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection")
      @collection = @anki_package.collection
      @name = "test note type"
      @note_type = AnkiRecord::NoteType.new collection: @collection, name: @name
    end
    it "should instantiate a note type with collection attribute equal to the collection argument" do
      expect(@note_type.collection).to eq @collection
    end
    it "should instantiate a new note type which is added to the collection's @note_types attribute" do
      expect(@note_type.collection.note_types).to include @note_type
    end
    it "should instantiate a note type with an integer id" do
      expect(@note_type.id).to be_a Integer
    end
    it "should instantiate a note type with name attribute equal to the name argument" do
      expect(@note_type.name).to eq @name
    end
    it "should instantiate a non-cloze note type (a note type with the cloze attribute being false)" do
      expect(@note_type.cloze).to eq false
    end
    it "should instantiate a note type with usn attribute equal to -1" do
      expect(@note_type.usn).to eq(-1)
    end
    it "should instantiate a note type with sort_field attribute equal to 0" do
      expect(@note_type.sort_field).to eq 0
    end
    it "should instantiate a note type object with req attribute equal to an empty array" do
      expect(@note_type.req).to eq []
    end
    it "should instantiate a note type object with tags attribute equal to an empty array" do
      expect(@note_type.tags).to eq []
    end
    it "should instantiate a note type object with vers attribute equal to an empty array" do
      expect(@note_type.vers).to eq []
    end
    it "should instantiate a note type with the card_templates attribute being an empty array" do
      expect(@note_type.card_templates).to eq []
    end
    it "should instantiate a note type with the note_fields attribute being an empty array" do
      expect(@note_type.note_fields).to eq []
    end
    it "should instantiate a note type with a deck_id attribute of nil" do
      expect(@note_type.deck_id).to eq nil
    end
    it "should instantiate a note type with the tags attribute being an empty array" do
      expect(@note_type.tags).to eq []
    end
    context "should instantiate a note type with default CSS styling" do
      it "that defines styling for the 'card' CSS class" do
        expect(@note_type.css).to include ".card {"
      end
      it "that includes .card: color: black;" do
        expect(@note_type.css).to include "color: black;"
      end
      it "that includes .card: background-color: transparent;" do
        expect(@note_type.css).to include "background-color: transparent;"
      end
      it "that includes .card: text-align: center;" do
        expect(@note_type.css).to include "text-align: center;"
      end
    end
    # TODO: Remove cloze argument from the constructor; let it be set afterwards.
    # context "and with a cloze: true argument" do
    #   let(:cloze_argument) { true }
    #   it "should instantiate a cloze note type (a note type with the cloze attribute being true)" do
    #     expect(@note_type.cloze).to eq true
    #   end
    # end
  end

  describe "::new when passed no name or args arguments" do
    let(:note_type_instantiated_with_only_collection) do
      anki_package = AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection")
      AnkiRecord::NoteType.new collection: anki_package.collection
    end
    it "should throw an ArgumentError" do
      expect { note_type_instantiated_with_only_collection }.to raise_error ArgumentError
    end
  end

  describe "::new when passed name and args arguments" do
    let(:note_type_instantiated_with_both_args_and_name) do
      anki_package = AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection")
      AnkiRecord::NoteType.new collection: anki_package.collection, name: "namo", args: {}
    end
    it "should throw an ArgumentError" do
      expect { note_type_instantiated_with_both_args_and_name }.to raise_error ArgumentError
    end
  end

  describe "#save" do
    before(:all) do
      @anki_package = AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection")
      @collection = @anki_package.collection
      @name = "crazy note type"
      @crazy_note_type = AnkiRecord::NoteType.new collection: @collection, name: @name
      AnkiRecord::NoteField.new note_type: @crazy_note_type, name: "crazy front"
      AnkiRecord::NoteField.new note_type: @crazy_note_type, name: "crazy back"
      crazy_card_template = AnkiRecord::CardTemplate.new note_type: @crazy_note_type, name: "crazy card 1"
      crazy_card_template.question_format = "{{crazy front}}"
      crazy_card_template.answer_format = "{{crazy back}}"
      second_crazy_card_template = AnkiRecord::CardTemplate.new note_type: @crazy_note_type, name: "crazy card 2"
      second_crazy_card_template.question_format = "{{crazy back}}"
      second_crazy_card_template.answer_format = "{{crazy front}}"
      @crazy_note_type.save

      @col_models_hash = @collection.models_json
      @crazy_note_type_hash = @col_models_hash[@crazy_note_type.id.to_s]
      @tmpls_array = @crazy_note_type_hash["tmpls"]
      @flds_array = @crazy_note_type_hash["flds"]
    end
    it "should save the note type object's id as a key in the models column's JSON object in the collection.anki21 database" do
      expect(@col_models_hash.keys).to include @crazy_note_type.id.to_s
    end
    it "should save the note type object as a JSON object value, as the value of the note type object's id key, in the models JSON object" do
      expect(@crazy_note_type_hash).to be_a Hash
    end
    it "should save the note type object's two card templates as JSON object values in the models JSON object tmpls array value" do
      expect(@crazy_note_type_hash["tmpls"].count).to eq 2
    end
    it "should save the note type object's two fields as JSON object values in the models JSON object flds array value" do
      expect(@crazy_note_type_hash["flds"].count).to eq 2
    end
    it "should save the note type object as a JSON object value with the following keys:
      'id', 'name', 'type', 'mod', 'usn',
      'sortf', 'did', 'tmpls', 'flds', 'css',
      'latexPre', 'latexPost', 'latexsvg', 'req', and 'tags'" do
      %w[id name type mod usn sortf did tmpls flds css latexPre latexPost latexsvg req tags vers].each do |key|
        expect(@crazy_note_type_hash.keys).to include key
      end
    end
    context "should save the note type object as a JSON object value" do
      it "with the note type object's id attribute as the value for the id in the note type hash" do
        expect(@crazy_note_type_hash["id"]).to eq @crazy_note_type.id
      end
      it "with the note type object's name attribute as the value for the name key in the note type hash" do
        expect(@crazy_note_type_hash["name"]).to eq @crazy_note_type.name
      end
      it "with 0 for the value of the type in the note hash because this is a non-cloze note type" do
        expect(@crazy_note_type_hash["type"]).to eq 0
      end
      it "with the note type's last_modified_timestamp attribute as the value for the mod in the note type hash" do
        expect(@crazy_note_type_hash["mod"]).to eq @crazy_note_type.last_modified_timestamp
      end
      it "with -1 for the value of the usn key in the note hash" do
        expect(@crazy_note_type_hash["usn"]).to eq(-1)
      end
      it "with 0 for the value of the sortf key in the note hash" do
        expect(@crazy_note_type_hash["sortf"]).to eq 0
      end
      it "with the note type's deck_id for the value of the did key in the note hash" do
        expect(@crazy_note_type_hash["did"]).to eq @crazy_note_type.deck_id
      end
      it "with an array value for the tmpls key in the note hash" do
        expect(@crazy_note_type_hash["tmpls"].instance_of?(Array)).to eq true
      end
      context "with an array value for the tmpls key in the note hash" do
        it "with values which are hashes" do
          expect(@tmpls_array.all? { |tmpl| tmpl.instance_of?(Hash) }).to eq true
        end
        it "with hash values with keys that include: 'name', 'ord', 'qfmt', 'afmt', 'bqfmt', 'bafmt', 'did', 'bfont', 'bsize'" do
          %w[name ord qfmt afmt bqfmt bafmt did bfont bsize].each do |key|
            expect(@tmpls_array.all? { |tmpl| tmpl.keys.include? key }).to eq true
          end
        end
        context "with hash values with keys that include: 'name', 'ord', 'qfmt', 'afmt', 'bqfmt', 'bafmt', 'did', 'bfont', 'bsize'" do
          it "and the value for the name key should be equal to the name attribute of the card template" do
            expect(@tmpls_array.map { |tmpl| tmpl["name"] }).to eq ["crazy card 1", "crazy card 2"]
          end
          it "and the value for the ord key should be the ordinal_number attribute of the card template" do
            expect(@tmpls_array.map { |tmpl| tmpl["ord"] }).to eq [0, 1]
          end
          it "and the value for the qfmt key should be the question format string of the card template" do
            expect(@tmpls_array.map { |tmpl| tmpl["qfmt"] }).to eq ["{{crazy front}}", "{{crazy back}}"]
          end
          it "and the value for the qfmt key should be the answer format string of the card template" do
            expect(@tmpls_array.map { |tmpl| tmpl["afmt"] }).to eq ["{{crazy back}}", "{{crazy front}}"]
          end
          it "and the value for the did key should be the deck_id attribute of the card template" do
            expect(@tmpls_array.map { |tmpl| tmpl["did"] }).to eq [nil, nil]
          end
          it "and the value for the bfont key should be equal to the bfont attribute of the card template" do
            expect(@tmpls_array.map { |tmpl| tmpl["bfont"] }).to eq ["", ""]
          end
          it "and the value for the bsize key should be equal to the bsize attribute of the card template" do
            expect(@tmpls_array.map { |tmpl| tmpl["bsize"] }).to eq [0, 0]
          end
        end
      end
      it "with an array value for the flds key in the note hash" do
        expect(@crazy_note_type_hash["flds"].instance_of?(Array)).to eq true
      end
      context "with an array value for the flds key in the note hash" do
        it "with values which are hashes" do
          expect(@flds_array.all? { |fld| fld.instance_of?(Hash) }).to eq true
        end
        it "with hash values with keys that include: 'name', 'ord', 'sticky', 'rtl', 'font', 'size' and 'description'" do
          %w[name ord sticky rtl font size description].each do |key|
            expect(@flds_array.all? { |fld| fld.keys.include?(key) }).to eq true
          end
        end
        context "with hash values with keys that include: 'name', 'ord', 'sticky', 'rtl', 'font', 'size' and 'description'" do
          it "and the value for the name key should be the name attribute of the note field" do
            expect(@flds_array.map { |fld| fld["name"] }).to eq ["crazy front", "crazy back"]
          end
          it "and the value for the ord key should be the ordinal_number attribute of the note field" do
            expect(@flds_array.map { |fld| fld["ord"] }).to eq [0, 1]
          end
          it "and the value for the sticky key should be the sticky attribute of the note field" do
            expect(@flds_array.map { |fld| fld["sticky"] }).to eq [false, false]
          end
          it "and the value for the rtl key should be the right_to_left attribute of the note field" do
            expect(@flds_array.map { |fld| fld["rtl"] }).to eq [false, false]
          end
          it "and the value for the font key should be equal to the font_style attribute of the note field" do
            expect(@flds_array.map { |fld| fld["font"] }).to eq %w[Arial Arial]
          end
          it "and the value for the size key should be equal to the font_size attribute of the note field" do
            expect(@flds_array.map { |fld| fld["size"] }).to eq [20, 20]
          end
          it "and the value for the description key should be equal to the description attribute of the note field" do
            expect(@flds_array.map { |fld| fld["description"] }).to eq ["", ""]
          end
        end
      end
    end
  end

  describe "::new when passed an args hash (of the existing default basic note type)" do
    before(:all) do
      @anki_package = AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection")
      @collection = @anki_package.collection
      @basic_note_type_from_existing = AnkiRecord::NoteType.new(collection: @collection, args: basic_model_hash)
      @basic_note_type_from_existing.save
    end
    context "when the args hash is the default JSON object for the Basic note type exported from a fresh Anki 2.1.54 profile" do
      it "should instantiate a note type with collection attribute equal to the collection argument" do
        expect(@basic_note_type_from_existing.collection).to eq @collection
      end
      it "should instantiate a new note type which is added to the collection's note_types attribute" do
        expect(@collection.note_types).to include @basic_note_type_from_existing
      end
      it "should not change the number of note types in the collection's note_types attribute" do
        expect(@collection.note_types.count).to eq 5
      end
      it "should instantiate a note type object with id the same as the data" do
        expect(@basic_note_type_from_existing.id).to eq basic_model_hash["id"]
      end
      it "should instantiate a note type object with the same name as the data ('Basic')" do
        expect(@basic_note_type_from_existing.name).to eq "Basic"
      end
      it "should instantiate a note type object with the same usn as the data" do
        expect(@basic_note_type_from_existing.usn).to eq basic_model_hash["usn"]
      end
      it "should instantiate a note type object with sort_field attribute equal to the data's sortf value" do
        expect(@basic_note_type_from_existing.sort_field).to eq basic_model_hash["sortf"]
      end
      it "should instantiate a note type object with req attribute equal to the data's req value" do
        expect(@basic_note_type_from_existing.req).to eq basic_model_hash["req"]
      end
      it "should instantiate a note type object with tags attribute equal to the data's tags value" do
        expect(@basic_note_type_from_existing.tags).to eq basic_model_hash["tags"]
      end
      it "should instantiate a note type object with vers attribute equal to the data's vers value" do
        expect(@basic_note_type_from_existing.vers).to eq basic_model_hash["vers"]
      end
      it "should instantiate a non-cloze note type" do
        expect(@basic_note_type_from_existing.cloze).to eq false
      end
      it "should instantiate a note type with the same deck id as the data (NULL or nil)" do
        expect(@basic_note_type_from_existing.deck_id).to eq nil
      end
      it "should instantiate a note type where the deck method returns nil" do
        expect(@basic_note_type_from_existing.deck).to be_nil
      end
      it "should instantiate a note type with one card template" do
        expect(@basic_note_type_from_existing.card_templates.count).to eq 1
      end
      it "should instantiate a note type with a template with the name Card 1" do
        expect(@basic_note_type_from_existing.card_templates.first.name).to eq "Card 1"
      end
      it "should instantiate a note type with a template that is of type CardTemplate" do
        expect(@basic_note_type_from_existing.card_templates.all? { |obj| obj.instance_of?(AnkiRecord::CardTemplate) }).to eq true
      end
      it "should instantiate a note type with 2 fields" do
        expect(@basic_note_type_from_existing.note_fields.count).to eq 2
      end
      it "should instantiate a note type with 2 fields that are of class NoteField" do
        expect(@basic_note_type_from_existing.note_fields.all? { |obj| obj.instance_of?(AnkiRecord::NoteField) }).to eq true
      end
      it "should instantiate a note type with a 'Front' field and a 'Back' field" do
        expect(@basic_note_type_from_existing.note_fields.map(&:name).sort).to eq %w[Back Front]
      end
      it "should instantiate a note type with the CSS styling from the data" do
        expect(@basic_note_type_from_existing.css).to eq basic_model_hash["css"]
      end
      it "should instantiate a note type with the data's LaTeX preamble" do
        expect(@basic_note_type_from_existing.latex_preamble).to eq basic_model_hash["latexPre"]
      end
      it "should instantiate a note type with the data's LaTeX postamble" do
        expect(@basic_note_type_from_existing.latex_postamble).to eq basic_model_hash["latexPost"]
      end
      it "should instantiate a note type with latex_svg false" do
        expect(@basic_note_type_from_existing.latex_svg).to eq false
      end
      it "should instantiate a note type with nil tags attribute because it is missing from the data" do
        expect(@basic_note_type_from_existing.tags).to eq nil
      end
    end
  end

  describe "::new when when passed an args hash (of the default basic and reversed card note type)" do
    before(:all) do
      collection = AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection").collection
      @basic_and_reversed_card_note_type_from_existing = AnkiRecord::NoteType.new(collection: collection, args: basic_and_reversed_card_model_hash)
    end
    it "should instantiate a note type with two card templates" do
      expect(@basic_and_reversed_card_note_type_from_existing.card_templates.count).to eq 2
    end
  end

  subject(:note_type) do
    if defined?(cloze_argument)
      AnkiRecord::NoteType.new collection: collection_argument, name: name_argument, cloze: cloze_argument
    else
      AnkiRecord::NoteType.new collection: collection_argument, name: name_argument
    end
  end
  subject(:basic_note_type_from_existing) { AnkiRecord::NoteType.new(collection: collection_argument, args: basic_model_hash) }
  let(:name_argument) { "test note type" }
  let(:collection_argument) do
    anki_package = AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection")
    AnkiRecord::Collection.new(anki_package: anki_package)
  end

  describe "#field_names_in_order" do
    context "for the default Basic note type" do
      it "should return an array ['Front', 'Back'] which are the field names in the correct order" do
        expect(basic_note_type_from_existing.field_names_in_order).to eq %w[Front Back]
      end
    end
    context "for a note type with four custom fields" do
      it "should return an array with the field names in the correct order" do
        4.times { |i| AnkiRecord::NoteField.new note_type: note_type, name: "Field #{i + 1}" }
        expect(note_type.field_names_in_order).to eq ["Field 1", "Field 2", "Field 3", "Field 4"]
      end
    end
  end

  describe "#snake_case_field_names" do
    context "for the default Basic note type" do
      it "should return an array including the values 'front' and 'back'" do
        expect(basic_note_type_from_existing.snake_case_field_names).to eq %w[front back]
      end
    end
    context "for a note type with a note field called 'Crazy Note Field Name'" do
      it "should return an array including the value 'crazy_note_field_name'" do
        AnkiRecord::NoteField.new note_type: note_type, name: "Crazy Note Field Name"
        expect(note_type.snake_case_field_names).to eq ["crazy_note_field_name"]
      end
    end
    context "for a note type with a note field called 'Double  Spaces'" do
      it "should return an array including the value 'crazy_note_field_name'" do
        AnkiRecord::NoteField.new note_type: note_type, name: "Double  Spaces"
        expect(note_type.snake_case_field_names).to eq ["double__spaces"]
      end
    end
  end

  describe "#sort_field_name" do
    context "for the default Basic note type" do
      it "should return the name of the field used to sort, 'Front'" do
        expect(basic_note_type_from_existing.sort_field_name).to eq "Front"
      end
    end
  end

  describe "#snake_case_sort_field_name" do
    context "for the default Basic note type" do
      it "should return the name of the field used to sort, 'Front', but in snake_case: front" do
        expect(basic_note_type_from_existing.snake_case_sort_field_name).to eq "front"
      end
    end
    context "for a note type with a note field called 'Crazy Note Field Name' which is the sort field" do
      it "should return 'crazy_note_field_name'" do
        AnkiRecord::NoteField.new note_type: note_type, name: "Crazy Note Field Name"
        expect(note_type.snake_case_sort_field_name).to eq "crazy_note_field_name"
      end
    end
  end

  describe "#allowed_card_template_answer_format_field_names" do
    context "for a non-cloze note type" do
      it "should return an array with the string names of the note type's fields' names and 'FrontSide'" do
        expect(basic_note_type_from_existing.allowed_card_template_answer_format_field_names).to eq %w[Front Back FrontSide]
      end
    end
    context "for a cloze note type" do
      it "should return an array with the string names of the note type's fields' names, 'FrontSide', and the note type's fields' names prepended with 'cloze:'" do
        basic_note_type_from_existing.cloze = true
        expect(basic_note_type_from_existing.allowed_card_template_answer_format_field_names).to eq ["Front", "Back", "cloze:Front", "cloze:Back", "FrontSide"]
      end
    end
  end

  describe "#allowed_card_template_question_format_field_names" do
    context "for a non-cloze note type" do
      it "should return an array with the string names of the note type's fields' names" do
        expect(basic_note_type_from_existing.allowed_card_template_question_format_field_names).to eq %w[Front Back]
      end
    end
    context "for a cloze note type" do
      it "should return an array with the string names of the note type's fields' names and the note type's fields' names prepended with 'cloze:'" do
        basic_note_type_from_existing.cloze = true
        expect(basic_note_type_from_existing.allowed_card_template_question_format_field_names).to eq ["Front", "Back", "cloze:Front", "cloze:Back"]
      end
    end
  end

  describe "#find_card_template_by" do
    context "when passed a name argument where the note type does not have a card template with that name" do
      it "should return nil" do
        expect(basic_note_type_from_existing.find_card_template_by(name: "does not exist")).to eq nil
      end
    end
    context "when passed a name argument where the note type has a card template with that name" do
      it "should return a card template object" do
        expect(basic_note_type_from_existing.find_card_template_by(name: "Card 1").instance_of?(AnkiRecord::CardTemplate)).to eq true
      end
      it "should return a card template object with name equal to the name argument" do
        expect(basic_note_type_from_existing.find_card_template_by(name: "Card 1").name).to eq "Card 1"
      end
    end
  end

  describe "#deck=" do
    let(:default_deck) { basic_note_type_from_existing.collection.find_deck_by name: "Default" }
    context "when used to set the deck to be a deck object" do
      it "should set the deck object to be the deck" do
        basic_note_type_from_existing.deck = default_deck
        expect(basic_note_type_from_existing.deck).to eq default_deck
      end
    end
    context "when used to set the deck to a non-deck object" do
      it "should raise an ArgumentError" do
        expect { basic_note_type_from_existing.deck = "Meg" }.to raise_error ArgumentError
      end
    end
  end

  describe "#add_note_field" do
    it "should raise an ArgumentError when passed an argument which is not a note field" do
      expect { basic_note_type_from_existing.add_note_field("not valid") }.to raise_error ArgumentError
    end
  end

  describe "#add_card_template" do
    it "should raise an ArgumentError when passed an argument which is not a card template" do
      expect { basic_note_type_from_existing.add_card_template("not valid") }.to raise_error ArgumentError
    end
  end
end
