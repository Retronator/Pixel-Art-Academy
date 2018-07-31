AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.ArtStudio.Southeast extends HQ.ArtStudio.ContextWithArtworks
  @id: -> 'Retronator.HQ.ArtStudio.Southeast'

  @register @id()
  template: -> @constructor.id()

  @version: -> '0.0.1'

  @initialize()

  @FocusPoints:
    Pastels:
      x: 0.85
      y: 0.66

  @HighlightGroups:
    Pastels: ['africa', 'weCaughtOnFire']

  constructor: ->
    super

    @sceneSize =
      width: 480
      height: 250

    @horizontalParallaxFactor = 0

  canMoveLeft: ->
    return unless @canMove()

    @targetFocusPoint().x > 0.5

  canMoveRight: ->
    return unless @canMove()

    @targetFocusPoint().x < 1

  canMove: ->
    return if @dialogueMode()

    viewport = LOI.adventure.interface.display.viewport().viewportBounds
    scale = LOI.adventure.interface.display.scale()

    visibleSceneWidth = viewport.width() / scale
    visibleSceneWidth < 400

  events: ->
    super.concat
      'click .move-button.left': @onClickMoveButtonLeft
      'click .move-button.right': @onClickMoveButtonRight

  onClickMoveButtonLeft: ->
    @moveFocus
      focusPoint:
        x: 0.43
        y: 0.5
      speedFactor: 2

  onClickMoveButtonRight: ->
    @moveFocus
      focusPoint:
        x: 1
        y: 0.5
      speedFactor: 2
