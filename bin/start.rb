require 'bundler/setup'
Bundler.require(:default)

require_relative '../lib/external_sorting'

CHUNK_SIZE = 1000

input_filename = 'input_data.txt'
output_filename = "new_output.txt"

ExternalSorting.sort_large_file(input_filename: input_filename, output_filename: output_filename,
                                chunk_size: CHUNK_SIZE)
