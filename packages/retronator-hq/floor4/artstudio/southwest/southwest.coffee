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
    All:
      x: 0.57
      y: 0.32
    Pastels:
      x: 0.85
      y: 0.66
    Acrylics:
      x: 0.84
      y: 0.23
    WatercolorsWall:
      x: 0.42
      y: 0.21
    WatercolorsTable:
      x: 0.42
      y: 0.8
    Oils:
      x: 0.27
      y: 0.39

  @HighlightGroups:
    Pastels: ['africa', 'weCaughtOnFire']
    Acrylics: ['streetFighterIiTriptych']
    WatercolorsWall: ['blonde', 'dayAtTheBeach']
    WatercolorsTable: ['memchu']
    OilsWall: ['everybodyWantsToRuleTheWorld', 'desolation', 'oilPainting']
    OilsStorage: ['pop', 'nineToFive', 'concreteFeet', 'blueLandscape']

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
