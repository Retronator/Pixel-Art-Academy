AP = Artificial.Program

class AP.HashFunctions
  @circularShift5: (hash, next) ->
    # Circularly shift the hash 5 bits to the left.
    hash = (hash << 5) | (hash >>> 27)

    # Return the shifted hash with next xor-ed into it.
    hash ^ next
    
  @getObjectHash: (object, hashFunction) ->
    # Turn the object into a string and hash it.
    string = EJSON.stringify object
  
    hashCode = 0
  
    for characterIndex in [0...string.length]
      hashCode = hashFunction hashCode, string.charCodeAt characterIndex
  
    hashCode
