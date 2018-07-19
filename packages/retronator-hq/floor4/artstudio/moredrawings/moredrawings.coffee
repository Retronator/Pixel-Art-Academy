AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.ArtStudio.MoreDrawings extends HQ.ArtStudio.ContextWithArtworks
  @id: -> 'Retronator.HQ.ArtStudio.MoreDrawings'

  @register @id()
  template: -> @constructor.id()

  @version: -> '0.0.1'

  @fullName: -> "more drawings"
  @description: ->
    "
      More drawings are found in the east part of the studio.
    "

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
      height: 400

  onCommand: (commandResponse) ->
    moreDrawings = @options.parent

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.LookAt, moreDrawings]
      priority: 1
      action: =>
        moreDrawings.dialogueMode false
        moreDrawings.enterContext()
