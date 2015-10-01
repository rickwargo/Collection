# Collection is an Indexable, sparsely-implemented singly linked list of any value (Object), indexed by Fixnum.

class Collection
  INDEXING_BASE = 0

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

  attr_reader :length # Can not resize array length externally

  def initialize(size = 0)
    @head = nil
    @length = size
  end

  # represent array as a string
  def to_s
    str = '['
    each do |node|
      node_string = node.nil? ? 'nil' : "#{node}"
      str += ', ' unless str == '['
      str += node_string
    end
    str += ']'

    return str
  end

  # Retrieve object at :index, raising an exception if Out of Bounds
  def at(index)
    raise Error::InvalidIndexError if index < INDEXING_BASE or index > length - (1 - INDEXING_BASE)

    node = @head
    until node.nil?
      if node.index == index
        return node.value
      else
        node = node.next
      end
    end

    return nil
  end

  # Store :value at :index
  def store_at(value, index)

    raise Error::InvalidIndexError if index < INDEXING_BASE

    node = @head
    previous_node = nil
    until node.nil?
      if node.index == index
        node.value = value
        return
      else
        previous_node, node = node, node.next
      end
    end

    append(value, index)
  end

  # Implements :retrieve_at using brackets for syntactical sugar
  def [](index)
    at(index)
  end

  # Implements :store_at using brackets for syntactical sugar
  def []=(index, value)
    store_at(value, index)
  end

  # Append :value to the end of the collection, assigning it an index 1 greater than the max index
  # Returns the :value
  def push(value)
    append(value)
  end

  # Remove the last node of the collection and return it to the caller
  def pop
    node = @head
    @head = @head.next

    return node.value
  end

  # Sequentially iterate through all nodes
  def each
    INDEXING_BASE.upto(length - (1 - INDEXING_BASE)) do |index|
      yield at(index)
    end
  end

  # Sequentially iterate through all node indicies
  def each_index
    INDEXING_BASE.upto(length - (1 - INDEXING_BASE)) do |index|
      yield index
    end
  end

  private
    # Generic iterator for sequencing through nodes
    def iterate_sparse
      node = @head
      until node.nil?
        yield node
        node = node.next
      end
    end

    # Iterate through the existing nodes in the array collection
    def each_sparse
      iterate_sparse do |node|
        yield node
      end
    end

    # Iterate through the existing nodes in the array collection returning the index
    def each_index_sparse
      iterate_sparse do |node|
        yield node.index
      end
    end

  # Returns the number of items in the array
    def count
      len = 0
      node = @head
      until node.nil?
        len += 1
        node = node.next
      end

      return len
    end

  # Return the maximum index of the sparse array by sequencing through the nodes
    def find_max_index
      return nil if @head.nil? or @head.index.nil?

      max_i = @head.index
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
      previous_head, @head = @head, Node.new(value)
      @head.index = index
      @head.next = previous_head

      @length = index + (1 - INDEXING_BASE) if index + (1 - INDEXING_BASE) > @length

      return @head
    end
end
