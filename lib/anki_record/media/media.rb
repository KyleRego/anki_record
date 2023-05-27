# frozen_string_literal: true

module AnkiRecord
  # :nodoc:
  class Media
    attr_reader :media_file

    FILENAME = "media"

    def initialize(tmpdir:)
      media_file_path = FileUtils.touch("#{tmpdir}/#{FILENAME}")[0]
      @media_file = File.open(media_file_path, mode: "w")
      media_file.write("{}")
      media_file.close
    end
  end
end
