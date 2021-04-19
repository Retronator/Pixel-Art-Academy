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
    # words that go the other way around.
    wordsStartingWithAVowel = [
      "hammer", "handicap", "harbor", "hardware", "harvest", "headlight", "headline", "heel", "heir", "heirloom",
      "helicopter", "helmet", "hemisphere", "hen", "herbalist", "herbivores", "herd", "hero", "historical", "honour",
      "hook", "horizon", "horror", "horse", "hospital", "hostile", "hour", "hunter"
    ]

    wordsStartingWithAConsonant = [
      "eucalyptus", "eugenics", "eukaryote", "eulogy", "eunuch", "euphemism", "euphoria", "eurasian", "eureka",
      "euro", "euro", "european", "eustasy", "euthanasia", "ewe", "ewer", "one", "ubiquity", "ufo", "ufology",
      "ukulele", "unanimity", "unary", "uni", "unicorn", "uniform", "union", "unique", "unison", "unit", "unite",
      "unity", "universal", "universalism", "universalism", "universe", "university", "unix", "upsilon", "uranium",
      "urea", "urethra", "urinal", "urine", "usability", "usage", "user", "using", "usurper", "usury", "utensil",
      "uterus", "utilitarian", "utility", "utopia", "uvula", "uvular", "use"
    ]

    firstWord = phrase.split(/\W/)[0].toLowerCase()

    if firstWord in wordsStartingWithAVowel
      "an #{phrase}"

    else if firstWord in wordsStartingWithAConsonant
      "a #{phrase}"

    vowels = ['a', 'e', 'i', 'o', 'u']

    if phrase[0] in vowels
      "an #{phrase}"

    else
      "a #{phrase}"
