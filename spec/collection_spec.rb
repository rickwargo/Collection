require 'spec_helper'

describe Collection do

  let(:collection) { Collection.new }

  context 'when interrogating its interface' do
    it { is_expected.to respond_to(:to_s) }
    it { is_expected.to respond_to(:length, :each, :each_index, :pop) }
    it { is_expected.to respond_to(:at, :push).with(1).argument }
    it { is_expected.to respond_to(:store_at).with(2).arguments }
  end

  context 'when storing values' do
    it 'reads the value stored' do
      some_value = 'foo'
      index = Collection::INDEXING_BASE
      collection.store_at(some_value, index)
      expect(collection.at(index)).to be(some_value)
    end

    it 'stores and verifies given sequential values' do
      1.upto(5) do |n|
        some_value = 'foo #' + n.to_s
        index = n
        collection.store_at(some_value, index)
        expect(collection.at(index)).to eq(some_value)
      end
    end

    it 'stores and verifies given random values' do
      1.upto(5) do
        n = rand(1000000)
        some_value = 'foo #' + n.to_s
        index = n
        collection.store_at(some_value, index)
        expect(collection.at(index)).to be(some_value)
      end
    end

    it 'generates an error when the index is < ' + Collection::INDEXING_BASE.to_s do
      expect{collection.at(Collection::INDEXING_BASE-1)}.to raise_error(Collection::Error::InvalidIndexError)
    end

    it 'generates an error when the index is > length' do
      len = 10
      collection.store_at('foo', len)
      expect{collection.at(len + 1 + (1 - Collection::INDEXING_BASE))}.to raise_error(Collection::Error::InvalidIndexError)
    end
  end

  context 'when using brackets' do
    it 'can read a value at a given index' do
      some_value = 'foo'
      index = 4
      collection.store_at(some_value, index)
      expect(collection[index]).to be(some_value)
    end

    it 'can store a value at a given index' do
      some_value = 'foo'
      index = 4
      collection[index] = some_value
      expect(collection.at(index)).to be(some_value)
    end
  end

  context 'when instantiating' do
    it 'is empty' do
      expect(collection.length).to eq(0)
    end

    it 'does not have a value at index ' + Collection::INDEXING_BASE.to_s do
      expect{collection.at(Collection::INDEXING_BASE)}.to raise_error(Collection::Error::InvalidIndexError)
    end

    it 'can create create an array with a specified length' do
      len = 10
      col = Collection.new(len)
      expect(col.length).to eq(len)
    end
  end

  context 'when operating on the collection' do
    it 'can determine its length' do
      expect(collection.length).to eq(0)
    end

    it 'can push a value on the end of the list' do
      collection_test_length = 5
      1.upto(collection_test_length) do |n|
        some_value = 'foo #' + n.to_s
        index = n
        collection.push(some_value)
      end
      expect(collection.length).to be(collection_test_length)
    end

    it 'can pop a value off the end of the list' do
      collection_test_length = 5
      some_value = nil # define outside of the following block to capture the last value pushed on the array
      1.upto(collection_test_length) do |n|
        some_value = 'foo #' + n.to_s
        collection.push(some_value)
      end
      expect(collection.pop).to be(some_value) # ("foo ##{collection_test_length}")
    end

    it 'can push a value on the end of a sparse list' do
      index = 537
      some_value = 'foo'
      collection.store_at(some_value, index)
      expect(collection.push(some_value).index).to be(index + 1)
    end

    it 'can override an existing value at the initial index' do
      index = Collection::INDEXING_BASE
      old_value = 'foo'
      new_value = 'bar'
      collection.store_at(old_value, index)
      collection.store_at(new_value, index)
      expect(collection.at(index)).to eq(new_value)
    end

    it 'can override an existing value at a random index' do
      times = 5
      len = 10
      1.upto(len * times) do
        index = rand(len)  # small array size that will be over-written around 5 times
        old_value = 'foo'
        new_value = 'bar'
        collection.store_at(old_value, index)
        collection.store_at(new_value, index)
        expect(collection.at(index)).to eq(new_value)
      end
    end
  end

  context 'when checking collection validity' do
    it 'has a specific string representation as a string' do
      str = ''
      Collection::INDEXING_BASE.upto(13) do |n|
        some_value = 'foo #' + n.to_s
        str += ', ' unless str == ''
        str += some_value
        collection.store_at(some_value, n)
      end
      expect(collection.to_s).to eq('[' + str + ']')
    end

    it 'has a specific string representation as a string when inserting # items < length' do
      collection.store_at('two', 2)
      collection.store_at('four', 4)
      expect(collection.to_s).to eq('[nil, nil, two, nil, four]')
    end

    it 'can find the length of the array when inserting randomly' do
      max_n = 0
      1.upto(50) do
        n = rand(1000000)
        max_n = n if n > max_n  # determine the max value for testing

        some_value = 'foo #' + n.to_s
        collection.store_at(some_value, n)
      end
      expect(collection.length).to be(max_n + 1 - Collection::INDEXING_BASE)
    end
  end

  context 'when iterating through the list' do
    it 'sequences through all items' do
      values = []
      Collection::INDEXING_BASE.upto(3) do |n|
        some_value = 'foo #' + n.to_s
        values << some_value  # to test each iterator
        collection.store_at(some_value, n)
      end
      list = []
      collection.each { |element| list << element }
      expect(list).to contain_exactly(*values)
    end

    it 'sequences through all indexes' do
      max_index = 7
      collection.store_at('foo', max_index)
      list = []
      collection.each_index { |idx| list << idx }
      expect(list).to contain_exactly(*(Collection::INDEXING_BASE..max_index))
    end
  end

  context 'when storing different object types' do
    it 'has the same values as those stored' do
      elems = [:hello, 'abcde', 158, nil, [1,'b',3], 123.45]
      elems.each_index do |idx|
        collection.store_at(elems[idx], idx)
      end
      list = []
      collection.each { |value| list << value }
      expect(list).to contain_exactly(*elems)
    end
  end

end
