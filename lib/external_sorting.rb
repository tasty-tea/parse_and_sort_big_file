module ExternalSorting
  module_function

  def create_sorted_tempfile_chunks(input_filename, chunk_size)
    tempfiles = []

    File.open(input_filename) do |file|
      file.each_slice(chunk_size) do |lines|
        transactions = lines.map { |line| Transaction.parse(line.strip) }
        transactions = CustomSort.quicksort(transactions, :desc)

        tempfile = Tempfile.create(anonymous: true)
        tempfiles << tempfile

        transactions.each do |transac|
          tempfile.puts transac.to_s
        end
      end
    end

    tempfiles
  end

  def create_output_file(output_filename, input_files)
    current_lines = input_files.map { |file| file.gets&.chomp }

    # Используем алгоритм External sorting

    File.open(output_filename, "w") do |out|
      while current_lines.any? { |line| !line.nil? }
        max_index = find_max_index(current_lines)
        out.puts current_lines[max_index]

        next_line = input_files[max_index].gets
        current_lines[max_index] = next_line&.chomp
      end
    end
  end

  def find_max_index(lines)
    max_index = nil
    max_amount = nil

    lines.each_with_index do |line, idx|
      next if line.nil?

      amount = Transaction.parse(line.strip).amount
      if max_amount.nil? || amount > max_amount
        max_amount = amount
        max_index = idx
      end
    end

    max_index
  end
end
