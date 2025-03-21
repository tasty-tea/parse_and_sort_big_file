require "custom_sort"

RSpec.describe CustomSort do
  let(:unsorted_array) { [3, 40, 21, 18, 25, 49, 24, 45, 39, 28] }

  context 'using default method' do
    it 'quicksorts asc' do
      expect(CustomSort.quicksort(unsorted_array)).to eq([3, 18, 21, 24, 25, 28, 39, 40, 45, 49])
    end

    it 'quicksorts desc' do
      expect(CustomSort.quicksort(unsorted_array, :desc)).to eq([49, 45, 40, 39, 28, 25, 24, 21, 18, 3])
    end
  end

  context 'using specific methods' do
    let(:asc_sorted_array) { [3, 18, 21, 24, 25, 28, 39, 40, 45, 49] }
    let(:desc_sorted_array) { [49, 45, 40, 39, 28, 25, 24, 21, 18, 3] }

    it 'quicksorts asc' do
      expect(CustomSort.quicksort_asc(unsorted_array)).to eq(asc_sorted_array)
    end

    it 'quicksorts desc' do
      expect(CustomSort.quicksort_desc(unsorted_array)).to eq(desc_sorted_array)
    end
  end
end
