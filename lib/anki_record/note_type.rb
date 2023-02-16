# frozen_string_literal: true

require "pry"
require_relative "helpers/time_helper"

module AnkiRecord
  ##
  # NoteType represents an Anki note type (also called a model)
  class NoteType
    include AnkiRecord::TimeHelper
    attr_reader :name, :id

    def initialize(name:)
      raise ArgumentError unless name

      @id = milliseconds_since_epoch
      @name = name
      @fields = []
      @css = ""
    end
  end
end
