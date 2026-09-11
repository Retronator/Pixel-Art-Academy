_.mixin
  # Determines whether two arrays contain the same values in the same order.
  arraysHaveSameValues: (a, b) ->
    return false unless a instanceof Array and b instanceof Array
    return false unless a.length is b.length
    return false for value, index in a when value isnt b[index]

    true
