AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.ArtStudio.Northwest extends HQ.ArtStudio.ContextWithArtworks
  @id: -> 'Retronator.HQ.ArtStudio.Northwest'

  @register @id()
  template: -> @constructor.id()

  @version: -> '0.0.1'

  @initialize()

  @FocusPoints:
    Sketches:
      x: 1
      y: 1
    Realistic:
      x: 0.6
      y: 0.42
    Charcoal:
      x: 0.4
      y: 0.42
    Pastels:
      x: 0.08
      y: 0.44

  @HighlightGroups:
    Sketches: ['handStudy', 'hillary', 'retropolisInternationalSpacestationMainTower', 'humanAnatomyStudies']
    PencilsPortraits: ['blackLab', 'aBrutallySoftWoman', 'alexKaylynn', 'selfPortraitWithHair', 'night21', 'skogsra', 'withersFamily', 'kaley']
    PencilsRealistc: ['blackLab', 'aBrutallySoftWoman', 'alexKaylynn', 'selfPortraitWithHair', 'withersFamily']
    PencilsMechanical: ['skogsra', 'withersFamily']
    PencilsColored: ['kaley']
    PencilsEdgeShading: ['night21']
    Charcoal: ['evilIsLoveSpelledBackwards', 'inAFeeling', 'inAMoment', 'rodin']

  constructor: ->
    super

    @horizontalParallaxFactor = 2

    @sceneSize =
      width: 720
      height: 360

  canMoveLeft: ->
    return if @dialogueMode()

    @targetFocusPoint().x > 0

  canMoveRight: ->
    return if @dialogueMode()

    @targetFocusPoint().x < 1

  events: ->
    super.concat
      'click .move-button.left': @onClickMoveButtonLeft
      'click .move-button.right': @onClickMoveButtonRight

  onClickMoveButtonLeft: ->
    @moveFocus
      focusPoint:
        x: if @targetFocusPoint().x > 0.5 then 0.5 else 0
        y: 0.5
      speedFactor: 2

  onClickMoveButtonRight: ->
    @moveFocus
      focusPoint:
        x: if @targetFocusPoint().x < 0.5 then 0.5 else 1
        y: 0.5
      speedFactor: 2
