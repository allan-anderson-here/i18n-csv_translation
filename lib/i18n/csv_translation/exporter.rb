# frozen_string_literal: true

require 'yaml'
require 'csv'

module I18n
  module CsvTranslation
    class Exporter
      def initialize(col_sep: ';')
        @col_sep = col_sep
      end

      def export(path:, output:, files: '*.yml', exclude_keys: [], &block)
        @path   = path
        @files  = files
        @output = output
        @exclude_keys = exclude_keys

        translations = load_translations_into_hash(&block)
        save_translations_to_csv translations
      end

      private

      def load_translations_into_hash
        translations = {}

        Dir[current_path.join(@path, '**', @files)].sort.each do |file|
          process_file = if block_given?
                           yield(file)
                         else
                           true
                         end

          if process_file
            ymls = YAML.load_file file
            translations.merge! output_filename(file, yml_locale(ymls)) => flat_translation_hash(ymls.values.first)
          end
        end

        translations
      end

      def save_translations_to_csv(translations)
        CSV.open(@output, 'w', col_sep: @col_sep) do |csv|
          translations.each do |key, value|
            if value.is_a?(Hash)
              value.each do |inner_key, inner_value|
                next if @exclude_keys.detect{|key_to_exclude| inner_key.include?(key_to_exclude)}
                csv << [key, inner_key, inner_value]
              end
            else
              csv << [key, value]
            end
          end
        end
      end

      def flat_translation_hash(translations, parent = [])
        result = {}

        translations.each do |key, values|
          current_key = parent.dup << key

          if values.is_a?(Hash)
            result.merge! flat_translation_hash(values, current_key)
          else
            result[current_key.join('.')] = values
          end
        end

        result
      end

      def current_path
        Pathname.new(File.dirname(__FILE__))
      end

      def output_filename(file, old_locale)
        File.basename(file).gsub("#{old_locale}.", "")
      end

      def yml_locale(yml)
        yml.keys.first
      end
    end
  end
end
