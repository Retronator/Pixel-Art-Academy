LOI = LandsOfIllusions

LOI.Parser.Vocabulary.Keys =
  Directions:
    North: ''
    South: ''
    East: ''
    West: ''
    Northeast: ''
    Northwest: ''
    Southeast: ''
    Southwest: ''
    In: ''
    Out: ''
    Up: ''
    Down: ''
    Back: ''

  Verbs:
    GoToLocationName: ''
    GoToDirection: ''
    ExitLocation: ''
    TalkTo: ''
    LookAt: ''
    Look: ''
    Use: ''
    Press: ''
    Read: ''
    WhatIs: ''
    WhoIs: ''
    Get: ''
    SitDown: ''
    SitIn: ''
    Stand: ''
    Open: ''
    Close: ''
    Drink: ''
    DrinkFrom: ''
    Return: ''
    ReturnTo: ''
    GiveTo: ''
    UseIn: ''
    UseWith: ''
    ShowTo: ''
    Show: ''
    LookIn: ''
    WakeUp: ''
    Buy: ''

  IgnorePrepositions: ''

  Questions:
    WhichPlace: ''
    WhichThing: ''
    WhichPerson: ''
    WhichVerb: ''
    
  Debug:
    ResetSections: ''

# Generate vocabulary keys.
transformVocabularyKey = (prefix, keys) ->
  # Nothing to do on leaf nodes, simply return the text to be set.
  return prefix unless _.isObject keys

  # We are on an object node so transform each property in turn.
  for key of keys
    keys[key] = transformVocabularyKey "#{prefix}.#{key}", keys[key]

  # Return the modified keys.
  keys

for key of LOI.Parser.Vocabulary.Keys
  LOI.Parser.Vocabulary.Keys[key] = transformVocabularyKey key, LOI.Parser.Vocabulary.Keys[key]
