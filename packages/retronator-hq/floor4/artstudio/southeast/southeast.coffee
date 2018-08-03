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
    DigitalEquipment:
      x: 0.43
      y: 0.72
    Digital:
      x: 0.43
      y: 0.62
    Acrylics:
      x: 0.82
      y: 0.56

  @HighlightGroups:
    DigitalEmulation: ['desertMatejJan', 'reignite6']
    DigitalUnique: ['amazing', 'forestOfLiarsSunsetOnTheWoodBridge', 'theForgottenEmpire', 'unchartedBookCover', 'lioness', 'octobitDay2Astronaut']
    Acrylics: ['skullGirl3', 'blueGirl2', 'adventureTime', 'pumpkinRoad', 'escape']
    AcrylicsShoes: ['streetFighterConverseChucks']

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
    visibleSceneWidth < 350

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
