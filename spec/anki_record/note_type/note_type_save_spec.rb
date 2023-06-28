# frozen_string_literal: true

require_relative "../support/clean_slate_anki_package"

# rubocop:disable RSpec/ExampleLength
RSpec.describe AnkiRecord::NoteType, "#save" do
  include_context "when the anki package is a clean slate"

  let(:name) { "custom note type name" }
  let!(:custom_note_type) do
    custom_note_type = described_class.new(anki21_database:, name:)
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

  it "saves the note type and its note fields and card templates in the collection.anki21 models JSON" do
    collection_record_models = anki21_database.models_json
    collection_record_models_note_type = collection_record_models[custom_note_type.id.to_s]
    collection_record_models_note_type_tmpls = collection_record_models_note_type["tmpls"]
    collection_record_models_note_type_flds = collection_record_models_note_type["flds"]

    expect(collection_record_models.keys).to include custom_note_type.id.to_s
    expect(collection_record_models_note_type).to be_a Hash
    expect(collection_record_models_note_type["tmpls"].count).to eq 2
    expect(collection_record_models_note_type["flds"].count).to eq 2
    %w[id name type mod usn sortf did tmpls flds css latexPre latexPost latexsvg req].each do |key|
      expect(collection_record_models_note_type.keys).to include key
    end

    expect(collection_record_models_note_type["id"]).to eq custom_note_type.id

    expect(collection_record_models_note_type["name"]).to eq custom_note_type.name

    expect(collection_record_models_note_type["type"]).to eq 0

    expect(collection_record_models_note_type["mod"]).to eq custom_note_type.last_modified_timestamp

    expect(collection_record_models_note_type["usn"]).to eq(-1)

    expect(collection_record_models_note_type["sortf"]).to eq 0

    expect(collection_record_models_note_type["did"]).to eq custom_note_type.deck_id

    expect(collection_record_models_note_type["tmpls"].instance_of?(Array)).to be true

    expect(collection_record_models_note_type_tmpls.all? { |tmpl| tmpl.instance_of?(Hash) }).to be true

    %w[name ord qfmt afmt bqfmt bafmt did bfont bsize].each do |key|
      expect(collection_record_models_note_type_tmpls.all? { |tmpl| tmpl.key?(key) }).to be true
    end

    expect(collection_record_models_note_type_tmpls.map { |tmpl| tmpl["name"] }).to eq ["custom card 1", "custom card 2"]

    expect(collection_record_models_note_type_tmpls.map { |tmpl| tmpl["ord"] }).to eq [0, 1]

    expect(collection_record_models_note_type_tmpls.map { |tmpl| tmpl["qfmt"] }).to eq ["{{custom front}}", "{{custom back}}"]

    expect(collection_record_models_note_type_tmpls.map { |tmpl| tmpl["afmt"] }).to eq ["{{custom back}}", "{{custom front}}"]

    expect(collection_record_models_note_type_tmpls.map { |tmpl| tmpl["did"] }).to eq [nil, nil]

    expect(collection_record_models_note_type_tmpls.map { |tmpl| tmpl["bfont"] }).to eq ["", ""]

    expect(collection_record_models_note_type_tmpls.map { |tmpl| tmpl["bsize"] }).to eq [0, 0]

    expect(collection_record_models_note_type["flds"].instance_of?(Array)).to be true

    expect(collection_record_models_note_type_flds.all? { |fld| fld.instance_of?(Hash) }).to be true

    %w[name ord sticky rtl font size description].each do |key|
      expect(collection_record_models_note_type_flds.all? { |fld| fld.key?(key) }).to be true
    end

    expect(collection_record_models_note_type_flds.map { |fld| fld["name"] }).to eq ["custom front", "custom back"]

    expect(collection_record_models_note_type_flds.map { |fld| fld["ord"] }).to eq [0, 1]

    expect(collection_record_models_note_type_flds.map { |fld| fld["sticky"] }).to eq [false, false]

    expect(collection_record_models_note_type_flds.map { |fld| fld["rtl"] }).to eq [false, false]

    expect(collection_record_models_note_type_flds.map { |fld| fld["font"] }).to eq %w[Arial Arial]

    expect(collection_record_models_note_type_flds.map { |fld| fld["size"] }).to eq [20, 20]

    expect(collection_record_models_note_type_flds.map { |fld| fld["description"] }).to eq ["", ""]
  end
end
# rubocop:enable RSpec/ExampleLength
