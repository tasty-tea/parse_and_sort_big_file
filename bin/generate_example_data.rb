require_relative '../lib/test_tools'

# Generate custom file with random transaction data

TestTools.fill_input_file(filename: 'input_data.txt', lines_count: 10_000_000)
