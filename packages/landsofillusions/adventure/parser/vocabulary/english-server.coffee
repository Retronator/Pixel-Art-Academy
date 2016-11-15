AB = Artificial.Babel

# Generate all default english vocabulary words
words =
  Directions:
    North: ['north', 'n']
    South: ['south', 's']
    East: ['east', 'e']
    West: ['west', 'w']
    In: ['in', 'enter']
    Out: ['out', 'exit']

  Verbs:
    Go: ['go']
    Talk: ['talk']
    Look: ['look', 'examine']
    Use: ['use']
    Press: ['press', 'push']

# Generate default english translations.
generateDefaultTranslations = (id, words) ->
  if _.isObject words
    # We are on an object node so generate translations of each property in turn. This
    # also works on the array node, which will use indices as property names.
    for word of words
      generateDefaultTranslations "#{id}.#{word}", words[word]

  else
    # We are on the leaf node which is the default english word for this id.
    word = words

    # We add each word into the vocabulary namespace.
    AB.createTranslation 'LandsOfIllusions.Adventure.Parser.Vocabulary', id, word

for word of words
  generateDefaultTranslations word, words[word]
