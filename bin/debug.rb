# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/AbcSize

require "sqlite3"
require "json"
require "zip"

def output_apkg_info(file_path)
  puts file_path
  Zip::File.open(file_path) do |zip_file|
    zip_file.each do |entry|
      next unless entry.name == "collection.anki21"

      entry.extract
      anki_21_database = SQLite3::Database.open "collection.anki21"

      col_record = anki_21_database.execute("select * from col").first
      decks = col_record[8]
      puts "decks:"
      p JSON.parse decks
      2.times { puts }

      note_types = col_record[9]
      puts "note types:"
      JSON.parse(note_types).each do |nt|
        p nt
        2.times { puts }
      end

      notes_data = anki_21_database.execute "select * from notes"
      puts "notes_data:"
      notes_data.each { |nd| p nd }
      2.times { puts }

      cards_data = anki_21_database.execute "select * from cards"
      puts "cards_data:"
      cards_data.each { |cd| p cd }
      2.times { puts }
    end
  end
ensure
  File.delete("collection.anki21")
end

ARGV.each { |file_path| output_apkg_info(file_path) }

# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
