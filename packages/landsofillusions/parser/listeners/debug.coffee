AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Parser.DebugListener extends LOI.Adventure.Listener
  onCommand: (commandResponse) ->
    commandResponse.onExactPhrase
      form: [Vocabulary.Keys.Debug.ResetSections]
      action: =>
        section.reset() for section in LOI.adventure.currentSections()
        true
