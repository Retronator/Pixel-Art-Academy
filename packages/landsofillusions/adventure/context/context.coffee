AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Adventure.Context extends LOI.Adventure.Thing
  @illustration: -> 
    # Override to provide information about the illustration (name, height)
    # for this context. By default there is no illustration.
    null
  
  illustration: -> @constructor.illustration()

  @fullName: -> null # Contexts don't need to be named.

  onCommand: (commandResponse) ->
    # You can exit contexts with the back command.
    return unless LOI.adventure.currentContext() is @options.parent

    commandResponse.onExactPhrase
      form: [Vocabulary.Keys.Directions.Back]
      action: =>
        LOI.adventure.exitContext()
