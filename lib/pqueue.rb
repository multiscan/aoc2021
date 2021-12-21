class PriorityQueue
  def initialize()
    # in binary heap, each element have exactly two children. In an array they
    # can be stored systematically: 
    # if parent have index i => childrens have indes 2i and 2i+1 
    @q = []
  end
  # add an element to the queue. Element must be comparable (priority)
  def push(e)
    @q << e
    bubble_up(@q.size - 1)
  end

  def pop
    return nil if @q.empty?
    # swap root with the last element so it can be removed and bubble the last 
    # element down again
    swap(0, @q.size - 1)
    root = @q.pop
    bubble_down(0)
    root
  end


  def inspect
    @q.map{|e| e.to_s}.join(", ")
  end

  private

  def swap(i,j)
    @q[i], @q[j] = @q[j], @q[i]
  end

  def bubble_up(i)
    return if i < 1   # already the root element

    # if parent has already higher priority then return otherwise swap the two
    # and continue to bubble up
    parent_i = i / 2
    return if @q[parent_i] >= @q[i]
    swap(i, parent_i)

    bubble_up(parent_i)
  end

  def bubble_down(i)
    ibot = @q.size - 1
    
    child_i = i * 2

    # already at the bottom
    return if child_i > ibot

    # take the largest of the two children if there are two
    if (child_i < ibot)
      left_e = @q[child_i]
      right_e = @q[child_i + 1]
      child_i += 1 if right_e > left_e
    end

    return if @q[i] >= @q[child_i]

    swap(i, child_i)

    bubble_down(child_i)
  end

end
