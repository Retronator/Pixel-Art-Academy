AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.ArtStudio.Southwest extends HQ.ArtStudio.ContextWithArtworks
  @id: -> 'Retronator.HQ.ArtStudio.Southwest'

  @register @id()
  template: -> @constructor.id()

  @version: -> '0.0.1'

  @initialize()

  @FocusPoints:
    BackWall:
      x: 0.4
      y: 0.2
    Pens:
      x: 0.46
      y: 0.68
    Markers:
      x: 0.74
      y: 0.5

  @HighlightGroups:
    Pens: []
    PensCombine: []
    Markers: []
    MarkersCombine: []

  constructor: ->
    super

    @sceneSize =
      width: 480
      height: 330

  canMoveLeft: ->
    return unless @canMove()

    @targetFocusPoint().x > 0

  canMoveRight: ->
    return unless @canMove()

    @targetFocusPoint().x < 1

  canMove: ->
    return if @dialogueMode()

    viewport = LOI.adventure.interface.display.viewport().viewportBounds
    scale = LOI.adventure.interface.display.scale()

    visibleSceneWidth = viewport.width() / scale
    visibleSceneWidth < 430

  events: ->
    super.concat
      'click .move-button.left': @onClickMoveButtonLeft
      'click .move-button.right': @onClickMoveButtonRight

  onClickMoveButtonLeft: ->
    @moveFocus
      focusPoint:
        x: 0
        y: 0.5
      speedFactor: 2

  onClickMoveButtonRight: ->
    @moveFocus
      focusPoint:
        x: 1
        y: 0.5
      speedFactor: 2
