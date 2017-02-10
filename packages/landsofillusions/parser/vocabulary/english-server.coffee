AB = Artificial.Babel

# Generate all default english vocabulary phrases
phrases =
  Directions:
    North: ['north', 'n']
    South: ['south', 's']
    East: ['east', 'e']
    West: ['west', 'w']
    Northeast: ['northeast', 'ne']
    Northwest: ['northwest', 'nw']
    Southeast: ['southeast', 'se']
    Southwest: ['southwest', 'sw']
    In: ['in', 'enter', 'inside']
    Out: ['out', 'exit', 'outside']
    Up: ['up']
    Down: ['down']

  Verbs:
    GoToLocationName: ['go to', 'travel to']
    GoToDirection: ['go', 'towards', 'move', 'travel']
    Talk: ['talk to', 'speak with', 'chat with']
    Look: ['look at', 'examine']
    Use: ['use']
    Press: ['press', 'push']
    Read: ['read']
    What: ['what is']
    Get: ['get', 'take', 'pick up']
    Sit: ['sit down']
    Stand: ['stand up']
    Open: ['open']
    Close: ['close']

  IgnorePrepositions: ['to', 'with', 'is', 'at']

  Questions:
    WhichPlace: ['where']
    WhichThing: ['which']
    WhichPerson: ['who']
    WhichVerb: ['what']

# Generate default english translations.
generateDefaultTranslations = (id, phrases) ->
  if _.isObject phrases
    # We are on an object node so generate translations of each property in turn. This
    # also works on the array node, which will use indices as property names.
    for phrase of phrases
      generateDefaultTranslations "#{id}.#{phrase}", phrases[phrase]

  else
    # We are on the leaf node which is one of the default english phrases for this id.
    phrase = phrases

    # We add this phrase into the vocabulary namespace.
    AB.createTranslation 'LandsOfIllusions.Adventure.Parser.Vocabulary', id, phrase

for rootId, phraseGroup of phrases
  generateDefaultTranslations rootId, phraseGroup
