# Operations that deal with URL strings.

_.mixin
  shuffleSelf: (array) ->
    for i in [0..array.length - 2]
      # Find a random place to shuffle the current item to.
      j = _.random i, array.length - 1

      # Exchange i and j elements.
      value = array[j]
      array[j] = array[i]
      array[i] = value
