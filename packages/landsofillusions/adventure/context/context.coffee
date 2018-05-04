AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Adventure.Context extends LOI.Adventure.Thing
  # The maximum height of context's illustration. By default there is no illustration (height 0).
  @illustrationHeight: -> 0
  illustrationHeight: -> @constructor.illustrationHeight()

  @fullName: -> null # Contexts don't need to be named.

  onCommand: (commandResponse) ->
    # You can exit contexts with the back command.
    return unless LOI.adventure.currentContext() is @options.parent

    commandResponse.onExactPhrase
      form: [Vocabulary.Keys.Directions.Back]
      action: =>
        LOI.adventure.exitContext()
        true
