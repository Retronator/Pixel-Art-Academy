AB = Artificial.Babel

class AB.Helpers
  # Generates an array of phrases made out of 1 to maxWordsInPhrase sequential words from the text.
  # - text: text from which to generate phrases
  # - words: alternative to text, provide the array of words directly.
  # - maxWordsInPhrase: how many words can generated phrases have at most
  @generatePhrases: (options) ->
    words = options.words or _.words(options.text)

    # We generate all possible multiple-word phrases.
    phrases = []
    wordsCount = words.length

    # If no limit to number of words used in a phrase is given, generate all phrases.
    options.maxWordsInPhrase ?= wordsCount

    # We might not even have enough words to reach the maximum.
    maxWordsInPhrase = Math.min options.maxWordsInPhrase, wordsCount

    if maxWordsInPhrase > 1
      for wordsInPhraseCount in [2..maxWordsInPhrase]
        lastStartingWordIndex = wordsCount - wordsInPhraseCount
        
        for startingWordIndex in [0..lastStartingWordIndex]
          endingWordIndex = startingWordIndex + wordsInPhraseCount - 1
          
          wordsInPhrase = words[startingWordIndex..endingWordIndex]
          
          phrase = wordsInPhrase.join ' '
          phrases.push phrase

    words.concat phrases

  # Return a floating point number from 0 to 1, how likely the
  # given word appears in the text (considering typos and close matches).
  # - phrase: target phrase to search for
  # - text: text in which to search for
  # - maxWordsInPhrase: limit how long phrases from the text to compare to
  # - textPhrases: optional, text phrases to be directly matched against (instead of passing text)
  @phraseLikelihoodInText: (options) ->
    bestMatch = 0

    if options.text
      options.textPhrases = @generatePhrases
        text: options.text
        maxWordsInPhrase: options.maxWordsInPhrase

    # Match the target word to each phrase in the text.
    for phraseFromText in options.textPhrases
      distance = @levenshteinDistance options.phrase, phraseFromText

      # Normalize to original phrase length.
      match = 1 - distance / options.phrase.length

      bestMatch = Math.max bestMatch, match

    bestMatch

  # Returns the Levenshtein distance between two words. It is the minimum number of single-character
  # edits (insertions, deletions or substitutions) required to change one word into the other.
  @levenshteinDistance = (word1, word2) ->
    # Based on Stack Overflow answer:
    # http://stackoverflow.com/a/6638467
    n = word1.length
    m = word2.length
    return m if n is 0
    return n if m is 0

    d = []
    d[i] = [] for i in [0..n]
    d[i][0] = i for i in [0..n]
    d[0][j] = j for j in [0..m]

    for c1, i in word1
      for c2, j in word2
        cost = if c1 is c2 then 0 else 1
        d[i + 1][j + 1] = Math.min d[i][j + 1] + 1, d[i + 1][j] + 1, d[i][j] + cost

    d[n][m]
