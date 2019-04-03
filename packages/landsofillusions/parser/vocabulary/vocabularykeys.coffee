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
    Sleep: ''
    EndDay: ''
    Buy: ''
    Board: ''
    Listen: ''
    ListenTo: ''
    Say: ''
    HangOut: ''
    Cheat: ''
    Help: ''
    Create: ''
    Write: ''
    WriteOn: ''

    Be:
      Present:
        "1stPerson":
          Singular: ''
          Plural: ''
        "2ndPerson":
          Singular: ''
          Plural: ''
        "3rdPerson":
          Singular: ''
          Plural: ''

  Pronouns:
    Subjective:
      Feminine: ''
      Masculine: ''
      Neutral: ''
    Objective:
      Feminine: ''
      Masculine: ''
      Neutral: ''
    Adjective:
      Feminine: ''
      Masculine: ''
      Neutral: ''
    Possessive:
      Feminine: ''
      Masculine: ''
      Neutral: ''
    Reflexive:
      Feminine: ''
      Masculine: ''
      Neutral: ''

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
