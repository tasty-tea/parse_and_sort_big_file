require 'bundler/setup'
Bundler.require(:default)

require_relative '../lib/transaction'
require_relative '../lib/custom_sort'
require_relative '../lib/test_tools'

CHUNK_SIZE = 1000

# Это чудовище работает, но выглядит абсолютно ужаснейшим образом и не тестируется

file_index = 0
File.open('input_data.txt') do |file|
  file.each_slice(CHUNK_SIZE) do |lines|
    transactions = []
    lines.each do |line|
      transactions << Transaction.parse(line.strip)
    end

    transactions = CustomSort.quicksort(transactions, :desc)

    File.open("outputs/output_file_#{file_index}.txt", 'w') do |output_file|
      transactions.each do |transac|
        output_file.puts transac.to_s
      end
    end

    file_index += 1
  end
end

input_files = (0..(file_index - 1)).map { |i| "outputs/output_file_#{i}.txt" }
output_file = "new_output.txt"

file_handles = input_files.map { |fname| File.open(fname, "r") }
current_lines = file_handles.map { |file| file.gets&.chomp }


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

    next_line = file_handles[max_index].gets
    current_lines[max_index] = next_line&.chomp
  end
end

file_handles.each(&:close)

if TestTools.file_sorted?("new_output.txt", :desc) { |line| Transaction.parse(line.strip).amount }
  puts "Файл отсортирован!"
else
  puts "Файл не отсортирован!"
end
