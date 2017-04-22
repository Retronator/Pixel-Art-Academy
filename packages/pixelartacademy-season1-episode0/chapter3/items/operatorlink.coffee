LOI = LandsOfIllusions
PAA = PixelArtAcademy
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

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode0/chapter3/items/operatorlink.script'

  @initialize()

  constructor: ->
    super

    @operator = new HQ.Actors.Operator

  destroy: ->
    super

    @operator.destroy()

  isVisible: -> false

  # Script

  initializeScript: ->
    @setThings
      operator: @options.parent.operator

    @setCallbacks
      Exit: (complete) =>
        LOI.adventure.goToLocation HQ.LandsOfIllusions.Room
        LOI.adventure.goToTimeline PAA.TimelineIds.RealLife
        complete()

      Construct: (complete) =>
        LOI.adventure.goToLocation LOI.Construct.Loading
        complete()

  # Listener

  onCommand: (commandResponse) ->
    console.log "ccc"
    operatorLink = @options.parent
    operator = operatorLink.operator

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, [operatorLink.avatar, operator.avatar]]
      action: => @startScript()
