# Collection is an Indexable, sparse list of any value (Object), indexed by Fixnum.
# Only items that exist in collection should be returned, non-existent items should generate an exception
#   because nil would be an appropriate value to store at a specified index

class Object
  # Bake an index and next pointer into Objects for traversing a linked list
  attr_accessor :index_value
  attr_accessor :next_element
end

class Collection
  module Error
    class Standard < StandardError; end
    class NotFoundError < Standard
      def message
        "Element was not found in the collection at the specified index."
      end
    end

    class InvalidIndexError < Standard
      def message
        "Index into array is out of bounds."
      end
    end
  end

  INDEXING_BASE = 0

  attr_accessor :length

  def initialize(size = 0)
    @head = nil
    @length = size
  end

  # represent array as a string
  def to_s
    str = '['
    each do |element|
      element_string = element.nil? ? 'nil' : "\"#{element}\""
      str += ', ' unless str == '['
      str += element_string
    end
    str += ']'

    return str
  end

  # Retrieve object at :index, raising an exception if Out of Bounds
  def at(index)
    raise Error::InvalidIndexError if index < INDEXING_BASE or index > length - (1 - INDEXING_BASE)

    element = @head
    until element.nil?
      if element.index_value == index
        return element
      else
        element = element.next_element
      end
    end

    return nil
  end

  # Store :value at :index
  def store_at(index, value)

    raise Error::InvalidIndexError if index < INDEXING_BASE

    element = @head
    previous_element = nil
    until element.nil?
      if element.index_value == index
        # replace existing element with this value, updating links
        value.next_element = element.next_element
        if previous_element.nil? # updating @head element
          @head = value
          @head.index_value = index
        else
          previous_element.next_element = value
        end
        return
      else
        previous_element, element = element, element.next_element
      end
    end

    append(value, index)
  end

  # Implements :retrieve_at using brackets for the syntactical sugar
  def [](index)
    at(index)
  end

  # Implements :store_at using brackets for the syntactical sugar
  def []=(index, value)
    store_at(index, value)
  end

  # Append :value to the end of the collection, assigning it an index 1 greater than the max index
  # Returns the :value
  def push(value)
    append(value)
  end

  # Remove the last element of the collection and return it to the caller
  def pop
    element, @head = @head, element.next_element

    return element
  end

  def each
    INDEXING_BASE.upto(length - (1 - INDEXING_BASE)) do |index|
      yield at(index)
    end
  end

  def each_index
    INDEXING_BASE.upto(length - (1 - INDEXING_BASE)) do |index|
      yield index
    end
  end

  private
    # Generic iterator for sequencing through elements
    def iterate_sparse
      element = @head
      until element.nil?
        yield element
        element = element.next_element
      end
    end

    # Iterate through the existing elements in the array collection
    def each_sparse
      iterate_sparse do |element|
        yield element
      end
    end

    # Iterate through the existing elements in the array collection returning the index
    def each_index_sparse
      iterate_sparse do |element|
        yield element.index_value
      end
    end

  # Returns the number of items in the array
    def count
      len = 0
      element = @head
      until element.nil?
        len += 1
        element = element.next_element
      end

      return len
    end

  # Return the maximum index of the sparse array by sequencing through the elements
    def find_max_index
      return nil if @head.nil? or @head.index_value.nil?

      max_i = @head.index_value
      each_index_sparse do |index|
        max_i = index if index > max_i
      end

      return max_i
    end

  # Append :value to the end of the array, optionally setting the :index
    # Returns the :value
    def append(value, index=nil)
      if index.nil?
        max_i = find_max_index
        index = max_i.nil? ? INDEXING_BASE : max_i + 1
      end
      previous_head, @head = @head, value
      @head.index_value = index
      @head.next_element = previous_head

      @length = index + (1 - INDEXING_BASE) if index + (1 - INDEXING_BASE) > @length

      return @head
    end
end