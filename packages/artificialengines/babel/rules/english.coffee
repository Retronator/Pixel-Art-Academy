AB = Artificial.Babel

class AB.Rules.English
  @createPossessive: (noun) ->
    if _.last(noun) is 's'
      "#{noun}'"
      
    else
      "#{noun}'s"

  @createNounSeries: (nouns) ->
    return unless nouns
    
    switch nouns.length
      when 0 then ''
      when 1 then nouns[0]
      when 2 then "#{nouns[0]} and #{nouns[1]}"
      else
        nouns = _.clone nouns
        nouns[nouns.length - 1] = "and #{_.last nouns}"
        nouns.join ', '

  @createOrdinal: (integer) ->
    switch integer % 10
      when 1 then "#{integer}st"
      when 2 then "#{integer}nd"
      when 3 then "#{integer}rd"
      else "#{integer}th"

  @addIndefinitePronoun: (phrase) ->
    # We have to choose between a/an based on whether the word is pronounced with a starting consonant or vowel. We can
    # most often determine the pronunciation based on the letter, but we use a list of exception for common English
    # words that go the other way around or that can't have a pronoun.
    firstWord = phrase.split(/\W/)[0].toLowerCase()

    if firstWord in @uncountableNouns
      return phrase

    if firstWord in @nounsStartingWithAVowel
      "an #{phrase}"

    else if firstWord in @nounsStartingWithAConsonant
      "a #{phrase}"

    if phrase[0] in @vowels
      "an #{phrase}"

    else
      "a #{phrase}"
      
  @vowels = ['a', 'e', 'i', 'o', 'u']

  @uncountableNouns = [
    "accommodation", "advertising", "air", "aid", "advice", "anger", "art", "assistance", "bread", "business",
    "butter", "calm", "cash", "chaos", "cheese", "childhood", "clothing", "coffee", "content", "corruption",
    "courage", "currency", "damage", "danger", "darkness", "data", "determination", "economics", "education",
    "electricity", "employment", "energy", "entertainment", "enthusiasm", "equipment", "evidence", "failure", "fame",
    "fire", "flour", "food", "freedom", "friendship", "fuel", "furniture", "fun", "genetics", "gold", "grammar",
    "guilt", "hair", "happiness", "harm", "health", "heat", "help", "homework", "honesty", "hospitality", "housework",
    "humour", "imagination", "importance", "information", "innocence", "intelligence", "jealousy", "juice", "justice",
    "kindness", "knowledge", "labour", "lack", "laughter", "leisure", "literature", "litter", "logic", "love", "luck",
    "magic", "management", "metal", "milk", "money", "motherhood", "motivation", "music", "nature", "news",
    "nutrition", "obesity", "oil", "old age", "oxygen", "paper", "patience", "permission", "pollution", "poverty",
    "power", "pride", "production", "progress", "pronunciation", "publicity", "punctuation", "quality", "quantity",
    "racism", "rain", "relaxation", "research", "respect", "rice", "room", "rubbish", "safety", "salt", "sand",
    "seafood", "shopping", "silence", "smoke", "snow", "software", "soup", "speed", "spelling", "stress", "sugar",
    "sunshine", "tea", "tennis", "time", "tolerance", "trade", "traffic", "transportation", "travel", "trust",
    "understanding", "unemployment", "usage", "violence", "vision", "warmth", "water", "wealth", "weather", "weight",
    "welfare", "wheat", "width", "wildlife", "wisdom", "wood", "work", "yoga", "youth"
  ]
  
  @nounsStartingWithAVowel = [
    "hammer", "handicap", "harbor", "hardware", "harvest", "headlight", "headline", "heel", "heir", "heirloom",
    "helicopter", "helmet", "hemisphere", "hen", "herbalist", "herbivores", "herd", "hero", "historical", "honour",
    "hook", "horizon", "horror", "horse", "hospital", "hostile", "hour", "hunter"
  ]

  @nounsStartingWithAConsonant = [
    "eucalyptus", "eugenics", "eukaryote", "eulogy", "eunuch", "euphemism", "euphoria", "eurasian", "eureka",
    "euro", "euro", "european", "eustasy", "euthanasia", "ewe", "ewer", "one", "ubiquity", "ufo", "ufology",
    "ukulele", "unanimity", "unary", "uni", "unicorn", "uniform", "union", "unique", "unison", "unit", "unite",
    "unity", "universal", "universalism", "universalism", "universe", "university", "unix", "upsilon", "uranium",
    "urea", "urethra", "urinal", "urine", "usability", "usage", "user", "using", "usurper", "usury", "utensil",
    "uterus", "utilitarian", "utility", "utopia", "uvula", "uvular", "use"
  ]
