require_relative 'custom_sort'
require_relative 'transaction'

class ExternalSorting
  attr_accessor :input_filename, :output_filename, :chunk_size

  def self.call(input_filename:, output_filename:, chunk_size: 1000)
    new(input_filename, output_filename, chunk_size).call
  end

  def initialize(input_filename, output_filename, chunk_size)
    @input_filename = input_filename
    @output_filename = output_filename
    @chunk_size = chunk_size
  end

  def call
    tempfiles = create_sorted_tempfile_chunks(@input_filename, @chunk_size)

    create_output_file(@output_filename, tempfiles)
  end

  private

  def create_sorted_tempfile_chunks(input_filename, chunk_size, sorter: CustomSort, parser: Transaction)
    tempfiles = []

    File.open(input_filename) do |file|
      file.each_slice(chunk_size) do |lines|
        transactions = parse_transactions(lines, parser)
        transactions = sorter.quicksort(transactions, :desc)

        tempfiles << write_to_tempfile(transactions)
      end
    end

    tempfiles
  end

  def create_output_file(output_filename, input_files, parser: Transaction)
    current_lines = input_files.map { |file| file.gets&.chomp }

    # Используем алгоритм External sorting

    File.open(output_filename, "w") do |out|
      while current_lines.any? { |line| !line.nil? }
        max_index = find_max_index(current_lines, parser)
        out.puts current_lines[max_index]

        next_line = input_files[max_index].gets
        current_lines[max_index] = next_line&.chomp
      end
    end
  end

  def parse_transactions(lines, parser)
    lines.map { |line| parser.parse(line.strip) }
  end

  def write_to_tempfile(transactions)
    tempfile = Tempfile.create(anonymous: true)
    transactions.each { |transac| tempfile.puts transac.to_s }
    tempfile.rewind
    tempfile
  end

  def find_max_index(lines, parser)
    max_index = nil
    max_amount = nil

    lines.each_with_index do |line, idx|
      next if line.nil?

      amount = parser.parse(line.strip).amount
      if max_amount.nil? || amount > max_amount
        max_amount = amount
        max_index = idx
      end
    end

    max_index
  end
end
