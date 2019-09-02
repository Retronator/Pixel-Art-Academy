AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Adventure.Context extends LOI.Adventure.Thing
  @isPrivate: -> false # Override if people should be isolated in this context.

  @illustration: ->
    # Override to provide information about the illustration (name, height)
    # for this context. By default there is no illustration.
    null
  
  illustration: -> @constructor.illustration()

  @fullName: -> null # Contexts don't need to be named.

  onCommand: (commandResponse) ->
    # You can exit contexts with the back or continue commands.
    return unless LOI.adventure.currentContext() is @options.parent

    commandResponse.onExactPhrase
      form: [[Vocabulary.Keys.Directions.Back, Vocabulary.Keys.Verbs.Continue]]
      action: =>
        LOI.adventure.exitContext()
