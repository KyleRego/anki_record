# frozen_string_literal: true

module AnkiRecord
  # :nodoc:
  class Media
    attr_reader :anki_package, :media_file

    FILENAME = "media"

    def self.create_new(anki_package:)
      media = new
      media.create_initialize(anki_package:)
      media
    end

    def create_initialize(anki_package:)
      @anki_package = anki_package
      media_file_path = FileUtils.touch("#{anki_package.tmpdir}/#{FILENAME}")[0]
      @media_file = File.open(media_file_path, mode: "w")
      media_file.write("{}")
      media_file.close
    end

    def self.update_new(anki_package:)
      media = new
      media.update_initialize(anki_package:)
      media
    end

    def update_initialize(anki_package:)
      @anki_package = anki_package
      @media_file = File.open("#{anki_package.tmpdir}/#{FILENAME}", mode: "w")
      media_file.write("{}")
      media_file.close
    end
  end
end
