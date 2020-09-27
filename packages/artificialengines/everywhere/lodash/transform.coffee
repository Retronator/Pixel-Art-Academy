_.mixin
  # Like map, but mutates original array.
  transform: (array, transformFunction) ->
    for item, index in array
      array[index] = transformFunction item

    array
