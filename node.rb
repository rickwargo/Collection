# Node is an individual element of the array collection, responsible for providing indexing to the array.

class Node
  attr_accessor :index
  attr_accessor :value
  attr_accessor :next

  def initialize(value=nil)
    @value = value
  end
end