# frozen_string_literal: true

require 'spec_helper'

describe I18n::CsvTranslation::Importer do
  let(:file)        { File.dirname(__FILE__) }
  let(:input)       { Pathname.new(file).join('..', 'fixtures', 'de_foods.csv') }
  let(:output_path) { Pathname.new(file).join('..', '..', 'tmp', 'locales') }

  let(:file_names)  { %w[de.food.yml de.fruit.yml de.vegetables.yml] }

  let(:col_sep) { ';' }

  let(:expected_base_key_in_files) do
    {
      'de.food.yml' => 'fastfood',
      'de.fruit.yml' => 'fruit',
      'de.vegetables.yml' => 'vegetable'
    }
  end

  subject { described_class.new col_sep: col_sep }

  context 'when importing translated csv' do
    before do
      Dir.mkdir output_path unless Dir.exist? output_path
      subject.import input: input, path: output_path, new_locale: 'de'
    end

    it 'creates files with new locale in name' do
      Dir[output_path.join('**', '*.yml')].each do |file|
        expect(file_names).to include Pathname.new(file).basename.to_s
      end
    end

    it 'stores keys in their corresponding files' do
      Dir[output_path.join('**', '*.yml')].each do |file|
        ymls = YAML.load_file file
        basename = Pathname.new(file).basename.to_s

        expect(ymls['de'].keys).to eq [expected_base_key_in_files[basename]]
      end
    end
  end
end
