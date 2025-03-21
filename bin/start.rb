require 'bundler/setup'
require 'benchmark/memory'
Bundler.require(:default)

require_relative '../lib/external_sorting'

CHUNK_SIZE = 10_000

Benchmark.memory do |x|
  input_filename = 'input_data.txt'
  output_filename = "new_output.txt"
  
  x.report("Memory") { ExternalSorting.call(input_filename: input_filename, output_filename: output_filename,
                       chunk_size: CHUNK_SIZE) }
end
