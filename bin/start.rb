require 'bundler/setup'
Bundler.require(:default)

require_relative '../lib/transaction'
require_relative '../lib/custom_sort'
require_relative '../lib/external_sorting'
require_relative '../lib/test_tools'

CHUNK_SIZE = 1000

input_file = 'input_data.txt'
output_file = "new_output.txt"

tempfiles = ExternalSorting.create_sorted_tempfile_chunks(input_file, CHUNK_SIZE)
tempfiles.map(&:rewind)
ExternalSorting.create_output_file(output_file, tempfiles)

tempfiles.each(&:close)

if TestTools.file_sorted?("new_output.txt", :desc) { |line| Transaction.parse(line.strip).amount }
  puts "Файл отсортирован!"
else
  puts "Файл не отсортирован!"
end
