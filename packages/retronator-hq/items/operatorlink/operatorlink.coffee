LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Items.OperatorLink extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.Items.OperatorLink'

  @fullName: -> "operator neural link"
  @shortName: -> "operator"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

  @description: ->
    "
      This is a neural link with the operator who controls your immersion. It allows you to talk to them.
    "

  @defaultScriptUrl: -> 'retronator_retronator-hq/items/operatorlink/operatorlink.script'

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
        LOI.adventure.goToTimeline PAA.TimelineIds.Construct
        complete()

  # Listener

  onCommand: (commandResponse) ->
    operatorLink = @options.parent
    operator = operatorLink.operator

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, [operatorLink.avatar, operator.avatar]]
      priority: -1
      action: => @startScript()
