# frozen_string_literal: true

require "./spec/anki_record/support/anki_package_spec_helpers"

RSpec.describe AnkiRecord::AnkiPackage, "#zip" do
  include_context "anki package helpers"

  let(:new_anki_package_name) { "new_anki_package_file_name" }

  context "with default parameters" do
    before { anki_package.zip }

    it "deletes the temporary directory" do
      expect_the_temporary_directory_to_not_exist
    end

    it "saves one *.apkg file where * is the name argument" do
      expect(Dir.entries(".").include?("#{new_anki_package_name}.apkg")).to be true
    end
  end
end
