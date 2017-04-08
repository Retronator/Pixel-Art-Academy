LOI = LandsOfIllusions
HQ = Retronator.HQ
C3 = PixelArtAcademy.Season1.Episode0.Chapter3

Vocabulary = LOI.Parser.Vocabulary

class C3.Items.OperatorLink extends LOI.Adventure.Item
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter3.Items.OperatorLink'

  @fullName: -> "operator neural link"

  @shortName: -> "operator"

  @description: ->
    "
      This is a neural link with the operator who controls your immersion. It allows you to talk to them.
    "

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode0/chapter3/sections/construct/scenes/loading.script'

  @initialize()

  constructor: ->
    super

    @operator = new HQ.Actors.Operator


  initializeScript: ->
    @setThings
      operator: @options.parent.operator

    @setCallbacks
      Exit: (complete) =>
        LOI.adventure.goToLocation HQ.Locations.LandsOfIllusions.Room
        complete()

      Construct: (complete) =>
        LOI.adventure.goToLocation LOI.Construct.Locations.Loading
        complete()

  destroy: ->
    super

    @operator.destroy()

  isVisible: -> false

  onCommand: (commandResponse) ->
    operator = @options.parent.operator

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, operator.avatar]
      action: => @startScript()
