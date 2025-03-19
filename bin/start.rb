require 'bundler/setup'
Bundler.require(:default)

require_relative '../lib/transaction'
require_relative '../lib/custom_sort'
require_relative '../lib/test_tools'

CHUNK_SIZE = 1000

# Это чудовище работает, но выглядит абсолютно ужаснейшим образом и не тестируется

input_file = 'input_data.txt'
output_file = "new_output.txt"

tempfiles = []
File.open(input_file) do |file|
  file.each_slice(CHUNK_SIZE) do |lines|
    transactions = []
    lines.each do |line|
      transactions << Transaction.parse(line.strip)
    end

    transactions = CustomSort.quicksort(transactions, :desc)

    tempfile = Tempfile.create(anonymous: true)
    tempfiles << tempfile

    transactions.each do |transac|
      tempfile.puts transac.to_s
    end
  end
end

tempfiles.map(&:rewind)
current_lines = tempfiles.map { |file| file.gets&.chomp }

# Используем алгоритм External sorting

File.open(output_file, "w") do |out|
  while current_lines.any? { |line| !line.nil? }
    max_index = nil
    max_amount = nil

    current_lines.each_with_index do |line, idx|
      next if line.nil?

      amount = Transaction.parse(line.strip).amount
      if max_amount.nil? || amount > max_amount
        max_amount = amount
        max_index = idx
      end
    end

    out.puts current_lines[max_index]

    next_line = tempfiles[max_index].gets
    current_lines[max_index] = next_line&.chomp
  end
end

tempfiles.each(&:close)
tempfiles.each(&:unlink)

if TestTools.file_sorted?("new_output.txt", :desc) { |line| Transaction.parse(line.strip).amount }
  puts "Файл отсортирован!"
else
  puts "Файл не отсортирован!"
end
