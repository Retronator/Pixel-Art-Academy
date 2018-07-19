AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.ArtStudio.Drawings extends HQ.ArtStudio.ContextWithArtworks
  @id: -> 'Retronator.HQ.ArtStudio.Drawings'

  @register @id()
  template: -> @constructor.id()

  @version: -> '0.0.1'

  @fullName: -> "drawings"
  @description: ->
    "
      Various drawings are found in the north-west part of the studio.
    "

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

    @_focusPoint = x: 0.08, y: 1

    @sceneSize =
      width: 720
      height: 360

  onCommand: (commandResponse) ->
    drawings = @options.parent

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.LookAt, drawings]
      priority: 1
      action: =>
        drawings.dialogueMode false
        drawings.enterContext()

  onClickArtwork: (event) ->
    styleClasses = $(event.target).attr('class').split(' ')

    if 'aquatic-botanical' in styleClasses
      artworkFields = [
        'aquaticII'
        'aquaticIII'
        'aquaticV'
        'botanicalIII'
        'botanicalIX'
        'botanicalV'
      ]

    else
      artworkFields = (_.camelCase styleClass for styleClass in styleClasses)

    @displayArtworks artworkFields
