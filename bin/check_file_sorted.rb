require_relative '../lib/test_tools'
require_relative '../lib/transaction'

filename = "new_output.txt"
order = :desc

if TestTools.file_sorted?(filename, order) { |line| Transaction.parse(line.strip).amount }
  puts "Файл отсортирован!"
else
  puts "Файл не отсортирован!"
end
