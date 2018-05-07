AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Parser.HelpListener extends LOI.Adventure.Listener
  onCommand: (commandResponse) ->
    commandResponse.onExactPhrase
      form: [Vocabulary.Keys.Verbs.Help]
      action: =>
        help = window.open '/help', '_blank'
        help.focus()
