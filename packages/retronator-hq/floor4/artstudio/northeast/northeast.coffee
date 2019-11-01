AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.ArtStudio.Northeast extends HQ.ArtStudio.ContextWithArtworks
  @id: -> 'Retronator.HQ.ArtStudio.Northeast'

  @register @id()
  template: -> @constructor.id()

  @version: -> '0.0.1'

  @initialize()

  @FocusPoints:
    BackWall:
      x: 0.4
      y: 0.15
    CardinalCity:
      x: 0.4
      y: 0.2
    Pens:
      x: 0.46
      y: 0.68
    Markers:
      x: 0.74
      y: 0.47

  @HighlightGroups:
    PensAquaticBotanical: ['aquaticBotanical']
    PensInk: ['desert']
    PensCombine: ['kuria', 'neukom']
    Markers: ['day9', 'angel', 'survivor']
    MarkersCombine: ['cardinalCity', 'cardinalCityTools']

  constructor: ->
    super arguments...

    @sceneSize =
      width: 480
      height: 400
