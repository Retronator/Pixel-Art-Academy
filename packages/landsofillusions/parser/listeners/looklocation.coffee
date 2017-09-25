AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Parser.LookLocationListener extends LOI.Adventure.Listener
  onCommand: (commandResponse) ->
    commandResponse.onExactPhrase
      form: [Vocabulary.Keys.Verbs.Look]
      action: =>
        LOI.adventure.interface.resetInterface?()
