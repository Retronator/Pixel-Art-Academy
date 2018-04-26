AB = Artificial.Babel
LOI = LandsOfIllusions

class LOI.Parser.Vocabulary
  constructor: ->
    # Subscribe to the whole vocabulary namespace.
    @_translationSubscription = AB.subscribeNamespace 'LandsOfIllusions.Adventure.Parser.Vocabulary'

    # Create a vocabulary of phrases translated to user's language.
    @phrases = new ReactiveField {}

    @_translationAutorun = Tracker.autorun (computation) =>
      return unless @_translationSubscription.ready()

      vocabularyPhrases = {}

      # We have all translation documents downloaded from the server. Go over all vocabulary phrases and translate them.
      translate = (vocabularyLocation, phrase, phrases) =>
        if _.isObject phrases
          # We are on an object node so generate translations of each property in turn.
          vocabularyLocation[phrase] = {}

          for subPhrase of phrases
            translate vocabularyLocation[phrase], subPhrase, phrases[subPhrase]

        else
          # We are on the leaf node which has the vocabulary key of this phrase.
          vocabularyKey = phrases

          # We add a dot at the end so we don't match any other keys that have the same start as this one.
          keyPattern = "#{vocabularyKey}."

          # We use the \\ to output one \ into the regex. With the dot that
          # follows this will come down to \. which will match a literal dot.
          keyPattern = keyPattern.replace /\./g, '\\.'

          # Note: we don't use the global flag because that creates inconsistent
          # behavior when calling test on the regex inside existingTranslations.
          keyRegex = new RegExp keyPattern

          # Find all the translations that use this vocabulary key.
          translations = Artificial.Babel.existingTranslations @_translationSubscription.namespace, keyRegex

          # Translate all phrases and add them to this location.
          vocabularyLocation[phrase] = []
          
          for translation in translations
            translated = translation.translate()
            
            # Only add in the phrase if it actually has an entry for this language.
            if translated.language
              # Make lowercase and normalize (deburr) to basic latin letters.
              text = _.toLower _.deburr translated.text
              vocabularyLocation[phrase].push text

      for phrase of LOI.Parser.Vocabulary.Keys
        translate vocabularyPhrases, phrase, LOI.Parser.Vocabulary.Keys[phrase]

      # Update vocabulary with new phrases.
      @phrases vocabularyPhrases

  destroy: ->
    @_translationSubscription.stop()
    @_translationAutorun.stop()

  ready: ->
    @_translationSubscription.ready()

  getPhrases: (key) ->
    console.log "Getting phrases for", key, "from", @phrases() if LOI.debug
    _.nestedProperty @phrases(), key
