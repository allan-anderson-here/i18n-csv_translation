# frozen_string_literal: true

require 'yaml'
require 'csv'

module I18n
  module CsvTranslation
    class Exporter
      def initialize(col_sep: ';')
        @col_sep = col_sep
      end

      def export(path:, output:, files: '*.yml', exclude_keys: [], reference_language: '', target_language: '',  &block)
        @path   = path
        @files  = files
        @output = output
        @exclude_keys = exclude_keys
        @reference_language = reference_language
        @target_language = target_language

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
            existing_file = file.gsub(".#{@reference_language}.", ".#{@target_language}.")
            if File.file?(existing_file)
              existing_target_ymls = YAML.load_file existing_file
              translations.merge! "#{output_filename(existing_file, yml_locale(existing_target_ymls))}_existing" => flat_translation_hash(existing_target_ymls.values.first)
            end
            next if file.include?(".#{@target_language}.") #File is already imported as _existing
            ymls = YAML.load_file file
            translations.merge! output_filename(file, yml_locale(ymls)) => flat_translation_hash(ymls.values.first)
          end
        end

        translations
      end

      def save_translations_to_csv(translations)
        CSV.open(@output, 'w', col_sep: @col_sep) do |csv|
          translations.each do |key, value|
            next if key.include?('_existing')
            existing_translations = translations[key + '_existing']
            if value.is_a?(Hash)
              value.each do |inner_key, inner_value|
                next if @exclude_keys.detect{|key_to_exclude| inner_key.include?(key_to_exclude)}
                if existing_translations && existing_translations[inner_key].present?
                  csv << [key, inner_key, inner_value, existing_translations[inner_key]]
                else
                  csv << [key, inner_key, inner_value, nil]
                end
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
