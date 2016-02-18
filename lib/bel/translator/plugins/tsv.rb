# lib/bel/translator/plugins/tsv.rb
require 'bel'

module BEL::Translator::Plugins

  module Tsv

    ID          = :tsv
    NAME        = 'Tab-separated Translator'
    DESCRIPTION = 'This translator provides read/write functionality for BEL Nanopubs stored in TAB-separated files. This translator is intended to integrate with bel.rb.'
    MEDIA_TYPES = %i(text/tab-separated-values)
    EXTENSIONS  = %i(tsv tab)

    def self.create_translator(options = {})
      require_relative 'tsv/translator'
      TsvTranslator.new
    end

    def self.id
      ID
    end

    def self.name
      NAME
    end

    def self.description
      DESCRIPTION
    end

    def self.media_types
      MEDIA_TYPES
    end 

    def self.file_extensions
      EXTENSIONS
    end
  end
end
