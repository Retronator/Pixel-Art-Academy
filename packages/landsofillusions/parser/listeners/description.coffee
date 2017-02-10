AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary
Nodes = LOI.Adventure.Script.Nodes

class LOI.Parser.DescriptionListener extends LOI.Adventure.Listener
  onCommand: (commandResponse) ->
    currentActiveThings = LOI.adventure.currentActiveThings()

    for thing in currentActiveThings
      do (thing) ->
        commandResponse.onPhrase
          form: [[Vocabulary.Keys.Verbs.Look], thing.avatar]
          action: =>
            LOI.adventure.showDescription thing
