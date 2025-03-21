require_relative 'custom_sort'
require_relative 'transaction'

class ExternalSorting
  attr_accessor :input_filename, :output_filename, :chunk_size

  MAX_OPEN_FILES = 10

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

    multi_stage_merge(tempfiles, @output_filename)
  ensure
    cleanup_tempfiles(tempfiles)
  end

  private

  def create_sorted_tempfile_chunks(input_filename, chunk_size, sorter: CustomSort, parser: Transaction)
    tempfiles = []

    File.open(input_filename) do |file|
      buffer = []
      file.each_line.lazy.each do |line|
        parsed = parser.parse(line.strip)
        raise ArgumentError, 'Invalid transaction format' if parsed.nil?

        buffer << parsed
        if buffer.size >= chunk_size
          tempfiles << write_sorted_chunk(buffer, sorter)
          buffer.clear
        end
      end
      tempfiles << write_sorted_chunk(buffer, sorter) unless buffer.empty?
    end

    tempfiles
  end

  def write_sorted_chunk(transactions, sorter)
    sorted_transactions = sorter.quicksort(transactions, :desc)
    tempfile = Tempfile.new
    sorted_transactions.each { |t| tempfile.puts t.to_s }
    tempfile.close
    sorted_transactions.clear

    # Yeah, it's manual GC call
    # For some reason it's not called automatically on my machine
    # And script gets killed by system over memory overload
    ObjectSpace.garbage_collect
    tempfile
  end

  def parse_transactions(lines, parser)
    lines.map { |line| parser.parse(line.strip) }
  end

  def multi_stage_merge(tempfiles, final_output_filename, parser: Transaction)
    if tempfiles.size <= MAX_OPEN_FILES
      merge_files(tempfiles, final_output_filename)
    else
      intermediate_files = []
      tempfiles.each_slice(MAX_OPEN_FILES) do |group|
        intermediate_temp = Tempfile.create(anonymous: true)
        merge_files(group, intermediate_temp.path)
        intermediate_temp.rewind
        intermediate_files << intermediate_temp
      end
      multi_stage_merge(intermediate_files, final_output_filename)
    end
  end

  def merge_files(tempfiles, output_filename, parser: Transaction)
    # Let's try to prevent memory leak, we're going to juggle files
    files = tempfiles.map do |tempfile|
      File.open(tempfile.path)
    end

    current_lines = files.map { |file| file.gets&.chomp }

    File.open(output_filename, "w") do |out|
      while current_lines.any? { |line| !line.nil? }
        max_index = find_max_index(current_lines, parser)
        out.puts current_lines[max_index]
        next_line = files[max_index].gets
        current_lines[max_index] = next_line&.chomp
      end
    ensure
      cleanup_tempfiles(files)
    end
  end

  def cleanup_tempfiles(tempfiles)
    tempfiles&.each(&:close)
    tempfiles&.each { |file| file.unlink if file.is_a?(Tempfile) }
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
