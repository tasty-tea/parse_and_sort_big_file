require 'bundler/setup'
Bundler.require(:default)

require_relative '../lib/external_sorting'

# It's best to make it about 10% of max file size
CHUNK_SIZE = 10_000

input_filename = 'input_data.txt'
output_filename = "new_output.txt"

ExternalSorting.call(input_filename: input_filename, output_filename: output_filename,
                     chunk_size: CHUNK_SIZE)
