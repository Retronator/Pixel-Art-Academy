AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

# Command represents the words and phrases in a user command.
class LOI.Parser.Command
  constructor: (@command) ->
    # Make lowercase and normalize (deburr) to basic latin letter.
    @normalizedCommand = @_normalize @command

    # We generate all possible multiple-word phrases out of the command.
    @phrases = AB.Helpers.generatePhrases
      text: @normalizedCommand

    console.log "Command has possible phrases", @phrases if LOI.debug

  # Returns the likelihood of this command including at least one of the given phrases.
  has: (phrases) ->
    # If a single phrase is sent in, wrap it into an array.
    phrases = [phrases] if _.isString phrases

    likelihood = 0

    for phrase in phrases
      phraseLikelihood = AB.Helpers.phraseLikelihoodInText
        phrase: @_normalize phrase
        textPhrases: @phrases

      likelihood = Math.max likelihood, phraseLikelihood

    likelihood

  # Do we have an exact match with the phrase?
  is: (phrases) ->
    # If a single phrase is sent in, wrap it into an array.
    phrases = [phrases] if _.isString phrases

    likelihood = 0

    for phrase in phrases
      normalizedPhrase = @_normalize phrase
      distance = AB.Helpers.levenshteinDistance normalizedPhrase, @normalizedCommand

      # Normalize to original phrase length.
      phraseLikelihood = 1 - distance / normalizedPhrase.length

      likelihood = Math.max likelihood, phraseLikelihood

    likelihood
    
  _normalize: (string) ->
    # Remove whitespace, make lowercase and normalize (deburr) to basic latin letter.
    _.toLower _.deburr _.trim string
