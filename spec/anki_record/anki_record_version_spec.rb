# frozen_string_literal: true

RSpec.describe AnkiRecord do
  it "has a version number" do
    expect(AnkiRecord::VERSION).not_to be_nil
  end
end
