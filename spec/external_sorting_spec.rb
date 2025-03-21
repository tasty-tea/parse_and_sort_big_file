require 'tempfile'
require "external_sorting"

# Create fake Transaction and Sorter
# We can use normal ones, but it's better to test with less dependensies

DummyTransaction = Struct.new(:amount) do
  def to_s
    amount.to_s
  end

  def self.parse(str)
    return nil if str.empty?

    new(str.to_f)
  end
end

class DummySorter
  def self.quicksort(array, order)
    order == :desc ? array.sort_by(&:amount).reverse : array.sort_by(&:amount)
  end
end

RSpec.describe ExternalSorting do
  shared_context 'common context' do
    let(:chunk_size) { 3 }

    let(:output_file) do
      file = Tempfile.new('output')
      file.path
    end
  end

  before do
    stub_const('Transaction', DummyTransaction)
    stub_const('CustomSort', DummySorter)
  end

  describe '.call' do
    include_context 'common context'

    let(:input_file) do
      file = Tempfile.new('input')
      fake_transactions = ['9.0', '3.0', '1.0', '2.0', '4.0', '11.0', '999.0', '0.3', '55.55', '3.0'].join("\n")
      file.write(fake_transactions)
      file.rewind
      file.path
    end

    after do
      File.delete(input_file) if File.exist?(input_file)
      File.delete(output_file) if File.exist?(output_file)
    end

    it 'sorts transaction desc and outputs them to the file' do
      ExternalSorting.call(input_filename: input_file, output_filename: output_file, chunk_size: chunk_size)
      output_lines = File.read(output_file).split("\n")

      expect(output_lines).to eq(["999.0", "55.55", "11.0", "9.0", "4.0", "3.0", "3.0", "2.0", "1.0", "0.3"])
    end
  end

  context 'when file contains incorrectly parsed lines (or empty lines)' do
    include_context 'common context'

    let(:input_file) do
      file = Tempfile.new('input_invalid')
      file.write("3.0\n\n2.3\n4.9\n")
      file.rewind
      file.path
    end

    after do
      File.delete(input_file) if File.exist?(input_file)
      File.delete(output_file) if File.exist?(output_file)
    end

    it 'throws an exception ' do
      expect do
        ExternalSorting.call(input_filename: input_file, output_filename: output_file, chunk_size: chunk_size)
      end.to raise_error(ArgumentError, /Invalid transaction format/)
    end
  end

  context 'when input file doesnt exist' do
    include_context 'common context'

    let(:input_file) { 'non_existent_file.txt' }

    after do
      File.delete(output_file) if File.exist?(output_file)
    end

    it 'throws an error when input file doesnt exist' do
      expect do
        ExternalSorting.call(input_filename: input_file, output_filename: output_file, chunk_size: chunk_size)
      end.to raise_error(Errno::ENOENT)
    end
  end
end
