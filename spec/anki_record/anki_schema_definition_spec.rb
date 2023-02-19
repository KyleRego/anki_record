# frozen_string_literal: true

RSpec.describe AnkiRecord do
  it "has the Anki schema data definition language SQL statements in anki_schema_definition.rb" do
    expect(AnkiRecord::ANKI_SCHEMA_DEFINITION).not_to be nil
  end
end
