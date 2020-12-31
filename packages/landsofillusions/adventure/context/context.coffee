AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Adventure.Context extends LOI.Adventure.Thing
  @isPrivate: -> false # Override if people should be isolated in this context.

  @fullName: -> null # Contexts don't need to be named.

  onCommand: (commandResponse) ->
    # You can exit contexts with the back or continue commands.
    return unless LOI.adventure.currentContext() is @options.parent

    commandResponse.onExactPhrase
      form: [[Vocabulary.Keys.Directions.Back, Vocabulary.Keys.Verbs.Continue]]
      action: =>
        LOI.adventure.exitContext()
