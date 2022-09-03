AP = Artificial.Program

class AP.HashFunctions
  @circularShift5: (hash, next) ->
    # Circularly shift the hash 5 bits to the left.
    hash = (hash << 5) | (hash >>> 27)

    # Return the shifted hash with next xor-ed into it.
    hash ^ next
