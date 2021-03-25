# frozen_string_literal: true

require 'ostruct'
require 'yaml'

module CLI
  module SettingsAccessible
    FILE_NAME = 'settings.yml'

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      def settings
        @settings ||= begin
          settings_hash = YAML.load_file(FILE_NAME)
          OpenStruct.new(settings_hash)
        end
      end
    end

    def settings
      self.class.settings
    end
  end
end
