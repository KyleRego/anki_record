# frozen_string_literal: true

# TODO: refactor and rename these, possibly make tmpdir a parameter
def expect_num_anki21_files_in_package_tmpdir(num:)
  expect(Dir.entries(tmpdir).count { |file| file.match(ANKI_COLLECTION_21_REGEX) }).to eq num
end

def expect_num_anki2_files_in_package_tmpdir(num:)
  expect(Dir.entries(tmpdir).count { |file| file.match(ANKI_COLLECTION_2_REGEX) }).to eq num
end

def expect_media_file_in_tmpdir
  expect(Dir.entries(tmpdir).include?("media")).to be true
end

def expect_num_apkg_files_in_directory(num:, directory:)
  expect(Dir.entries(directory).count { |file| file.match(ANKI_PACKAGE_REGEX) }).to eq num
end

def expect_the_temporary_directory_to_not_exist
  expect(Dir.exist?(tmpdir)).to be false
end
