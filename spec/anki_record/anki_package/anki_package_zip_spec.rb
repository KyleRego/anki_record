# frozen_string_literal: true

require "./spec/anki_record/support/clean_slate_anki_package"
require "./spec/anki_record/support/anki_package_files_helpers"

RSpec.describe AnkiRecord::AnkiPackage, "#zip" do
  include_context "when the anki package is a clean slate"

  before { anki_package.zip }

  context "when the package was instantiated with a name argument that does not end with .apkg" do
    it "zips a file with that name and ending in .apkg" do
      expect(File.exist?("#{clean_slate_anki_package_name}.apkg")).to be true
    end

    it "deletes the temporary directory" do
      expect_the_temporary_directory_to_not_exist
    end
  end

  context "when the package was instantiated with a name argument that ends with .apkg" do
    let(:clean_slate_anki_package_name) { "clean_slate_anki_package.apkg" }

    it "zips a file with that name" do
      expect(File.exist?(clean_slate_anki_package_name)).to be true
    end

    it "deletes the temporary directory" do
      expect_the_temporary_directory_to_not_exist
    end
  end
end
