module TestTools
  module_function

  def fill_input_file(filename: 'input_data.txt', lines_count: 10_000)
    File.open('input_data.txt', 'w') do |file|
      lines_count.times do
        file.puts "2023-09-03T12:45:00Z,txn12345,user987,#{rand(0..100_000).to_f / 100}"
      end
    end
  end

  def file_sorted?(file_path, order = :asc)
    File.open(file_path, "r") do |file|
      first_line = file.gets
      return true unless first_line

      prev_value = yield(first_line.chomp)

      file.each_line do |line|
        current_value = yield(line.chomp)
        if order == :asc
          return false if prev_value > current_value
        elsif order == :desc
          return false if prev_value < current_value
        else
          raise ArgumentError, "Unknown order: #{order}. Use :asc or :desc."
        end
        prev_value = current_value
      end
    end
    true
  end
end
