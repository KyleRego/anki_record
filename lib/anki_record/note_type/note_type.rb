# frozen_string_literal: true

require_relative "../card_template/card_template"
require_relative "../helpers/shared_constants_helper"
require_relative "../helpers/time_helper"
require_relative "../note_field/note_field"
require_relative "note_type_attributes"
require_relative "note_type_defaults"

module AnkiRecord
  ##
  # NoteType represents an Anki note type (also called a model).
  #
  # The attributes are documented in the NoteTypeAttributes module.
  class NoteType
    include Helpers::SharedConstantsHelper
    include Helpers::TimeHelper
    include NoteTypeAttributes
    include NoteTypeDefaults

    NOTE_TYPES_WITHOUT_TAGS_AND_VERS_VALUES = ["Basic", "Basic (and reversed card)",
                                               "Basic (optional reversed card)", "Basic (type in the answer)"].freeze

    def initialize(collection:, name: nil, args: nil)
      raise ArgumentError unless (name && args.nil?) || (args && args["name"])

      @collection = collection

      if args
        setup_note_type_instance_variables_from_existing(args:)
      else
        setup_instance_variables_for_new_note_type(name:)
      end

      @collection.add_note_type self
      save
    end

    ##
    # Saves the note type to the collection.anki21 database
    def save
      collection_models_hash = collection.models_json
      collection_models_hash[@id] = to_h
      sql = "update col set models = ? where id = ?"
      collection.anki21_database.prepare(sql).execute([JSON.generate(collection_models_hash), collection.id])
    end

    def to_h # :nodoc:
      self_to_h = { id: @id, name: @name, type: @cloze ? 1 : 0,
                    mod: @last_modified_timestamp, usn: @usn, sortf: @sort_field, did: @deck_id,
                    tmpls: @card_templates.map(&:to_h), flds: @note_fields.map(&:to_h), css: @css,
                    latexPre: @latex_preamble, latexPost: @latex_postamble, latexsvg: @latex_svg,
                    req: @req }
      self_to_h.merge({ tags: @tags, vers: @vers }) unless NOTE_TYPES_WITHOUT_TAGS_AND_VERS_VALUES.include?(@name)
      self_to_h
    end

    ##
    # Returns the note type object's card template with name +name+ or nil if it is not found
    def find_card_template_by(name:)
      card_templates.find { |template| template.name == name }
    end

    ##
    # Returns an array of the note type's fields' names ordered by field ordinal values.
    def field_names_in_order
      @note_fields.sort_by(&:ordinal_number).map(&:name)
    end

    def snake_case_field_names # :nodoc:
      field_names_in_order.map { |field_name| field_name.downcase.tr(" ", "_") }
    end

    ##
    # Returns the name of the note type's field used to sort notes in the browser.
    def sort_field_name
      @note_fields.find { |field| field.ordinal_number == @sort_field }&.name
    end

    def snake_case_sort_field_name # :nodoc:
      sort_field_name.downcase.tr(" ", "_")
    end

    ##
    # Returns allowed field_name values in {{field_name}} in the question format.
    def allowed_card_template_question_format_field_names
      allowed = field_names_in_order
      cloze ? allowed + field_names_in_order.map { |field_name| "cloze:#{field_name}" } : allowed
    end

    ##
    # Returns allowed field_name values in {{field_name}} in the answer format.
    def allowed_card_template_answer_format_field_names
      allowed_card_template_question_format_field_names + ["FrontSide"]
    end

    def add_note_field(note_field) # :nodoc:
      raise ArgumentError unless note_field.instance_of?(AnkiRecord::NoteField)

      @note_fields << note_field
    end

    def add_card_template(card_template) # :nodoc:
      raise ArgumentError unless card_template.instance_of?(AnkiRecord::CardTemplate)

      @card_templates << card_template
    end

    private

      def setup_note_type_instance_variables_from_existing(args:)
        setup_collaborator_object_instance_variables_from_existing(args:)
        setup_simple_instance_variables_from_existing(args:)
      end

      def setup_collaborator_object_instance_variables_from_existing(args:)
        @note_fields = []
        args["flds"].each { |fld| NoteField.new(note_type: self, args: fld) }
        @card_templates = []
        args["tmpls"].each { |tmpl| CardTemplate.new(note_type: self, args: tmpl) }
      end

      def setup_simple_instance_variables_from_existing(args:)
        %w[id name usn css req tags vers].each do |note_type_attribute|
          instance_variable_set "@#{note_type_attribute}", args[note_type_attribute]
        end
        @cloze = args["type"] == 1
        @last_modified_timestamp = args["mod"]
        @sort_field = args["sortf"]
        @deck_id = args["did"]
        @latex_preamble = args["latexPre"]
        @latex_postamble = args["latexPost"]
        @latex_svg = args["latexsvg"]
      end

      def setup_instance_variables_for_new_note_type(name:)
        @name = name
        @cloze = false
        setup_collaborator_object_instance_variables_for_new_note_type
        setup_simple_instance_variables_for_new_note_type
      end

      def setup_collaborator_object_instance_variables_for_new_note_type
        @note_fields = []
        @card_templates = []
      end

      def setup_simple_instance_variables_for_new_note_type
        @id = milliseconds_since_epoch
        @last_modified_timestamp = seconds_since_epoch
        @usn = NEW_OBJECT_USN
        @sort_field = default_note_type_sort_field
        @deck_id = @tags = @vers = nil
        @css = default_css
        @latex_preamble = default_latex_preamble
        @latex_postamble = default_latex_postamble
        @latex_svg = false
        @req = []
      end
  end
end
