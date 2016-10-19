AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Parser.Command
  constructor: (@command) ->
    # Make lowercase and normalize (deburr) to basic latin letter.
    @normalizedCommand = _.toLower _.deburr @command
    @commandWords = _.words @normalizedCommand

  # Does this command include any of the words?
  has: (words) ->
    # If a single word is sent in, wrap it into an array.
    words = [words] if _.isString words

    for word in words
      # Make lowercase and normalize (deburr) to basic latin letter.
      word = _.toLower _.deburr word

      # We have the word if it is found somewhere in the command.
      return true if @normalizedCommand.indexOf(word) > -1

    # We didn't find the word.
    false
