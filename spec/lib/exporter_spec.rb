# frozen_string_literal: true

require 'spec_helper'

describe I18n::CsvTranslation::Exporter do
  let(:file)       { File.dirname(__FILE__) }
  let(:path)       { Pathname.new(file).join('..', 'fixtures', 'locales') }
  let(:output)     { Pathname.new(file).join('..', '..', 'tmp', 'export.csv') }
  let(:parsed_csv) { CSV.open(output, col_sep: col_sep).readlines }
  let(:col_sep)    { ';' }

  let(:file_names) { %w[food.yml fruit.yml vegetables.yml] }

  subject { described_class.new col_sep: col_sep }

  context 'output file' do
    context 'without block' do
      before do
        subject.export(path: path, output: output)
      end

      it 'stores the original file name without locale' do
        parsed_csv.each do |line|
          expect(file_names).to include line[0]
        end
      end

      it 'has the i18n key' do
        # Test for all keys?
        expect(parsed_csv.first[1]).to eq 'fastfood.pizza'
      end

      it 'has the i18n value' do
        expect(parsed_csv.first[2]).to eq 'Pizza'
      end

      it 'omits the locale in the keys' do
        parsed_csv.each do |line|
          expect(line[1]).to_not start_with('en')
        end
      end
    end

    context 'with block' do
      let(:ignored_file) { 'en.food.yml' }

      before do
        subject.export(path: path, output: output) { |file| !file.include?(ignored_file) }
      end

      it 'can ignore file' do
        parsed_csv.each do |line|
          expect(ignored_file).to_not include line[0]
        end
      end
    end

    context 'with non default csv column separator' do
      let(:col_sep) { "\t" }

      it 'saves with custom separator' do
        expect(CSV).to receive(:open).with(output, 'w', col_sep: col_sep)

        subject.export(path: path, output: output)
      end
    end
  end
end
