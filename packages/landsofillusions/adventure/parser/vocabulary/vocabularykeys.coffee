LOI = LandsOfIllusions

LOI.Adventure.Parser.Vocabulary.Keys =
  Directions:
    North: ''
    South: ''
    East: ''
    West: ''
    In: ''
    Out: ''
    
  Verbs:
    Go: ''
    Talk: ''

# Generate vocabulary keys.
transformVocabularyKey = (prefix, keys) ->
  # Nothing to do on leaf nodes, simply return the text to be set.
  return prefix unless _.isObject keys

  # We are on an object node so transform each property in turn.
  for key of keys
    keys[key] = transformVocabularyKey "#{prefix}.#{key}", keys[key]

  # Return the modified keys.
  keys

for key of LOI.Adventure.Parser.Vocabulary.Keys
  LOI.Adventure.Parser.Vocabulary.Keys[key] = transformVocabularyKey key, LOI.Adventure.Parser.Vocabulary.Keys[key]
