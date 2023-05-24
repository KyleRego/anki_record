# frozen_string_literal: true

require "./spec/anki_record/support/anki_package_spec_helpers"

RSpec.describe AnkiRecord::AnkiPackage, "#zip" do
  include_context "anki package helpers"

  context "when the package was instantiated with a name argument that does not end with .apkg" do
    let(:new_anki_package_name) { "test" }

    before { anki_package.zip }

    it "zips a file with that name and ending in .apkg" do
      expect(File.exist?("#{new_anki_package_name}.apkg")).to be true
    end

    it "deletes the temporary directory" do
      expect_the_temporary_directory_to_not_exist
    end
  end

  context "when the package was instantiated with a name argument that ends with .apkg" do
    let(:new_anki_package_name) { "test.apkg" }

    before { anki_package.zip }

    it "zips a file with that name" do
      expect(File.exist?(new_anki_package_name)).to be true
    end

    it "deletes the temporary directory" do
      expect_the_temporary_directory_to_not_exist
    end
  end
end
