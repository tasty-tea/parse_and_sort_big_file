require 'bundler/setup'
Bundler.require(:default)

require_relative '../lib/transaction'
require_relative '../lib/custom_sort'
require_relative '../lib/external_sorting'
require_relative '../lib/test_tools'

CHUNK_SIZE = 1000

input_filename = 'input_data.txt'
output_filename = "new_output.txt"

begin
  tempfiles = ExternalSorting.create_sorted_tempfile_chunks(input_filename, CHUNK_SIZE)
  tempfiles.map(&:rewind)

  ExternalSorting.create_output_file(output_filename, tempfiles)
ensure
  tempfiles&.each(&:close)
end
