module CustomSort
  module_function

  def quicksort(array, order = :asc)
    return quicksort_asc(array) if order == :asc
    return quicksort_desc(array) if order == :desc

    raise ArgumentError, "Unknown order: #{order}. Use :asc or :desc."
  end

  def quicksort_asc(array)
    return [] if array.empty?

    pivot = array[array.size / 2]
    left = array.select { |x| x < pivot }
    middle = array.select { |x| x == pivot }
    right = array.select { |x| x > pivot }

    quicksort_asc(left) + middle + quicksort_asc(right)
  end

  def quicksort_desc(array)
    return [] if array.empty?

    pivot = array[array.size / 2]
    left = array.select { |x| x > pivot }
    middle = array.select { |x| x == pivot }
    right = array.select { |x| x < pivot }

    quicksort_desc(left) + middle + quicksort_desc(right)
  end
end
