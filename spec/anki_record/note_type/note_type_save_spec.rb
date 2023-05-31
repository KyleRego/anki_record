# frozen_string_literal: true

require_relative "../support/clean_slate_anki_package"

# rubocop:disable RSpec/ContextWording
# rubocop:disable RSpec/NestedGroups
# rubocop:disable RSpec/MultipleMemoizedHelpers

RSpec.describe AnkiRecord::NoteType, "#save" do
  include_context "when the anki package is a clean slate"

  let(:name) { "custom note type name" }
  let!(:custom_note_type) do
    custom_note_type = described_class.new collection: collection, name: name
    AnkiRecord::NoteField.new note_type: custom_note_type, name: "custom front"
    AnkiRecord::NoteField.new note_type: custom_note_type, name: "custom back"
    custom_card_template = AnkiRecord::CardTemplate.new note_type: custom_note_type, name: "custom card 1"
    custom_card_template.question_format = "{{custom front}}"
    custom_card_template.answer_format = "{{custom back}}"
    second_custom_card_template = AnkiRecord::CardTemplate.new note_type: custom_note_type, name: "custom card 2"
    second_custom_card_template.question_format = "{{custom back}}"
    second_custom_card_template.answer_format = "{{custom front}}"
    custom_note_type.save
    custom_note_type
  end

  let(:col_models_hash) { collection.models_json }
  let(:custom_note_type_hash) { col_models_hash[custom_note_type.id.to_s] }
  let(:tmpls_array) { custom_note_type_hash["tmpls"] }
  let(:flds_array) { custom_note_type_hash["flds"] }

  it "saves the note type object's id as a key in the models column's JSON object in the collection.anki21 database" do
    expect(col_models_hash.keys).to include custom_note_type.id.to_s
  end

  it "saves the note type object as a JSON object value, as the value of the note type object's id key, in the models JSON object" do
    expect(custom_note_type_hash).to be_a Hash
  end

  it "saves the note type object's two card templates as JSON object values in the models JSON object tmpls array value" do
    expect(custom_note_type_hash["tmpls"].count).to eq 2
  end

  it "saves the note type object's two fields as JSON object values in the models JSON object flds array value" do
    expect(custom_note_type_hash["flds"].count).to eq 2
  end

  it "saves the note type object as a JSON object value with the following keys: 'id', 'name', 'type', 'mod', 'usn', 'sortf', 'did', 'tmpls', 'flds', 'css', 'latexPre', 'latexPost', 'latexsvg', and 'req'" do
    %w[id name type mod usn sortf did tmpls flds css latexPre latexPost latexsvg req].each do |key|
      expect(custom_note_type_hash.keys).to include key
    end
  end

  context "saves the note type as a JSON value" do
    it "with the note type object's id attribute as the value for the id in the note type hash" do
      expect(custom_note_type_hash["id"]).to eq custom_note_type.id
    end

    it "with the note type object's name attribute as the value for the name key in the note type hash" do
      expect(custom_note_type_hash["name"]).to eq custom_note_type.name
    end

    it "with 0 for the value of the type in the note hash because this is a non-cloze note type" do
      expect(custom_note_type_hash["type"]).to eq 0
    end

    it "with the note type's last_modified_timestamp attribute as the value for the mod in the note type hash" do
      expect(custom_note_type_hash["mod"]).to eq custom_note_type.last_modified_timestamp
    end

    it "with -1 for the value of the usn key in the note hash" do
      expect(custom_note_type_hash["usn"]).to eq(-1)
    end

    it "with 0 for the value of the sortf key in the note hash" do
      expect(custom_note_type_hash["sortf"]).to eq 0
    end

    it "with the note type's deck_id for the value of the did key in the note hash" do
      expect(custom_note_type_hash["did"]).to eq custom_note_type.deck_id
    end

    it "with an array value for the tmpls key in the note hash" do
      expect(custom_note_type_hash["tmpls"].instance_of?(Array)).to be true
    end

    context "with an array value for the tmpls key in the note hash" do
      it "with values which are hashes" do
        expect(tmpls_array.all? { |tmpl| tmpl.instance_of?(Hash) }).to be true
      end

      it "with hash values with keys that include: 'name', 'ord', 'qfmt', 'afmt', 'bqfmt', 'bafmt', 'did', 'bfont', 'bsize'" do
        %w[name ord qfmt afmt bqfmt bafmt did bfont bsize].each do |key|
          expect(tmpls_array.all? { |tmpl| tmpl.key?(key) }).to be true
        end
      end

      context "with hash values with keys that include: 'name', 'ord', 'qfmt', 'afmt', 'bqfmt', 'bafmt', 'did', 'bfont', 'bsize'" do
        it "and the value for the name key should be equal to the name attribute of the card template" do
          expect(tmpls_array.map { |tmpl| tmpl["name"] }).to eq ["custom card 1", "custom card 2"]
        end

        it "and the value for the ord key should be the ordinal_number attribute of the card template" do
          expect(tmpls_array.map { |tmpl| tmpl["ord"] }).to eq [0, 1]
        end

        it "and the value for the qfmt key should be the question format string of the card template" do
          expect(tmpls_array.map { |tmpl| tmpl["qfmt"] }).to eq ["{{custom front}}", "{{custom back}}"]
        end

        it "and the value for the qfmt key should be the answer format string of the card template" do
          expect(tmpls_array.map { |tmpl| tmpl["afmt"] }).to eq ["{{custom back}}", "{{custom front}}"]
        end

        it "and the value for the did key should be the deck_id attribute of the card template" do
          expect(tmpls_array.map { |tmpl| tmpl["did"] }).to eq [nil, nil]
        end

        it "and the value for the bfont key should be equal to the bfont attribute of the card template" do
          expect(tmpls_array.map { |tmpl| tmpl["bfont"] }).to eq ["", ""]
        end

        it "and the value for the bsize key should be equal to the bsize attribute of the card template" do
          expect(tmpls_array.map { |tmpl| tmpl["bsize"] }).to eq [0, 0]
        end
      end
    end

    it "with an array value for the flds key in the note hash" do
      expect(custom_note_type_hash["flds"].instance_of?(Array)).to be true
    end

    context "with an array value for the flds key in the note hash" do
      it "with values which are hashes" do
        expect(flds_array.all? { |fld| fld.instance_of?(Hash) }).to be true
      end

      it "with hash values with keys that include: 'name', 'ord', 'sticky', 'rtl', 'font', 'size' and 'description'" do
        %w[name ord sticky rtl font size description].each do |key|
          expect(flds_array.all? { |fld| fld.key?(key) }).to be true
        end
      end

      context "with hash values with keys that include: 'name', 'ord', 'sticky', 'rtl', 'font', 'size' and 'description'" do
        it "and the value for the name key should be the name attribute of the note field" do
          expect(flds_array.map { |fld| fld["name"] }).to eq ["custom front", "custom back"]
        end

        it "and the value for the ord key should be the ordinal_number attribute of the note field" do
          expect(flds_array.map { |fld| fld["ord"] }).to eq [0, 1]
        end

        it "and the value for the sticky key should be the sticky attribute of the note field" do
          expect(flds_array.map { |fld| fld["sticky"] }).to eq [false, false]
        end

        it "and the value for the rtl key should be the right_to_left attribute of the note field" do
          expect(flds_array.map { |fld| fld["rtl"] }).to eq [false, false]
        end

        it "and the value for the font key should be equal to the font_style attribute of the note field" do
          expect(flds_array.map { |fld| fld["font"] }).to eq %w[Arial Arial]
        end

        it "and the value for the size key should be equal to the font_size attribute of the note field" do
          expect(flds_array.map { |fld| fld["size"] }).to eq [20, 20]
        end

        it "and the value for the description key should be equal to the description attribute of the note field" do
          expect(flds_array.map { |fld| fld["description"] }).to eq ["", ""]
        end
      end
    end
  end
end
# rubocop:enable RSpec/ContextWording
# rubocop:enable RSpec/NestedGroups
# rubocop:enable RSpec/MultipleMemoizedHelpers
