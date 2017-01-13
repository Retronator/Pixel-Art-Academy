AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

# Command response captures the listener's response to a command. It contains all the information for the UI to provide
# feedback to the player in case the command is ambiguous or the conditions for its execution are not met.
class LOI.Parser.CommandResponse
  @MatchingModes:
    Exact: 'Exact'
    Includes: 'Includes'

  constructor: (@options) ->
    @requiredAvatars = []
    @matchingPhraseActions = []

  # Notes that any of this actions are valid only if the provided avatar has been named.
  requireAvatar: (avatar) ->
    @requiredAvatars.push avatar

  # Register an action that happens when the given phrase (or any of the aliases) is present somewhere in the command.
  onPhrase: (phraseAction) ->
    @matchingPhraseActions.push
      phraseAction: phraseAction
      matchingMode: @constructor.MatchingModes.Includes

  # Register an action that happens when the command is exactly the given phrase (or any of the aliases).
  onExactPhrase: (phraseAction) ->
    @matchingPhraseActions.push
      phraseAction: phraseAction
      matchingMode: @constructor.MatchingModes.Exact

  generateActions: ->
    baseLikelihood = 1

    # If any avatar is required to execute this action, make sure you can find it in the command.
    for avatar in @requiredAvatars
      shortNameWords = _.words avatar.shortName()
      fullNameWords = _.words avatar.fullName()
      possibleNameWords = _.union shortNameWords, fullNameWords
    
      avatarLikelihood = @options.command.has possibleNameWords
      
      # The likelihood of this avatar being found affects the whole likelihood of this response's actions.
      baseLikelihood *= avatarLikelihood

    likelyActions = for matchingPhraseAction in @matchingPhraseActions
      phraseAction = matchingPhraseAction.phraseAction
      matchingMode = matchingPhraseAction.matchingMode

      phrasesLikeliehood = 0

      # Find all translations for the possible phrases used (the main one and the aliases).
      phraseKeys = _.union [phraseAction.phraseKey], phraseAction.aliasKeys

      translatedPhrases = for phraseKey in phraseKeys
        @options.parser.vocabulary.getPhrases phraseKey

      translatedPhrases = _.flatten translatedPhrases

      # Return an array of likely actions, one for each phrase translation.
      for translatedPhrase in translatedPhrases
        # Calculate how likely this phrase is in the command.
        switch matchingMode
          when @constructor.MatchingModes.Exact
            likelihood = @options.command.is translatedPhrase

          when @constructor.MatchingModes.Includes
            likelihood = @options.command.has translatedPhrase

        console.log "for phrase", translatedPhrase, "likelihood in mode", matchingMode, "is", likelihood if LOI.debug

        # Return an action with the given combined likelihood that this is what the user wanted.
        phraseAction: phraseAction
        likelihood: baseLikelihood * likelihood
        translatedPhrase: translatedPhrase

    # Likely actions include nested arrays for all actions so we return a flattened version.
    _.flattenDeep likelyActions
