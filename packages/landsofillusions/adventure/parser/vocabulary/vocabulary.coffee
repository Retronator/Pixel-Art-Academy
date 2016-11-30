AB = Artificial.Babel
LOI = LandsOfIllusions

class LOI.Adventure.Parser.Vocabulary
  constructor: ->
    # Subscribe to the whole vocabulary namespace.
    @_translationSubscription = AB.subscribeNamespace 'LandsOfIllusions.Adventure.Parser.Vocabulary'

    # Create a vocabulary of words translated to user's language.
    @words = new ReactiveField {}

    @_translationAutorun = Tracker.autorun (computation) =>
      return unless @_translationSubscription.ready()

      vocabularyWords = {}

      # We have all translation documents downloaded from the server. Go over all vocabulary words and translate them.
      translate = (vocabularyLocation, word, words) =>
        if _.isObject words
          # We are on an object node so generate translations of each property in turn.
          vocabularyLocation[word] = {}

          for subWord of words
            translate vocabularyLocation[word], subWord, words[subWord]

        else
          # We are on the leaf node which has the vocabulary key of this word.
          vocabularyKey = words

          # We add a dot at the end so we don't match any other keys that have the same start as this one.
          keyPattern = "#{vocabularyKey}."

          # We use the \\ to output one \ into the regex. With the dot that
          # follows this will come down to \. which will match a literal dot.
          keyPattern = keyPattern.replace /\./g, '\\.'

          keyRegex = new RegExp keyPattern, 'g'

          # Find all the translations that use this vocabulary key.
          translations = Artificial.Babel.Translation.documents.find(
            namespace: @_translationSubscription.namespace
            key:
              $regex: keyRegex
          ).fetch()

          # Translate all words and add them to this location.
          vocabularyLocation[word] = []
          
          for translation in translations
            translated = translation.translate()
            
            # Only add in the word if it actually has an entry for this language.
            if translated.language
              # Make lowercase and normalize (deburr) to basic latin letter.
              text = _.toLower _.deburr translated.text
              vocabularyLocation[word].push text

      for word of LOI.Adventure.Parser.Vocabulary.Keys
        translate vocabularyWords, word, LOI.Adventure.Parser.Vocabulary.Keys[word]

      # Update vocabulary with new words.
      @words vocabularyWords

  destroy: ->
    @_translationSubscription.stop()
    @_translationAutorun.stop()

  ready: ->
    @_translationSubscription.ready()

  getWords: (key) ->
    console.log "Getting words for", key, "from", @words() if LOI.debug
    _.nestedProperty @words(), key
