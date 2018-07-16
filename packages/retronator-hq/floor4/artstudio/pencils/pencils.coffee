AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.ArtStudio.Pencils extends HQ.ArtStudio.ContextWithArtworks
  @id: -> 'Retronator.HQ.ArtStudio.Pencils'

  @register @id()
  template: -> @constructor.id()

  @version: -> '0.0.1'

  @initialize()

  @HighlightGroups:
    Inventory: ['inventory']

  constructor: ->
    super

    @artistsInfo =
      matejJan: name: first: 'Matej', last: 'Jan'

    @artworksInfo =
      inventory:
        artistInfo: @artistsInfo.matejJan
        title: 'Inventory'
        caption: "Drawing tools test sheet, 9 × 12 inches (crop)"

  onCreated: ->
    super

    @handVisible = new ReactiveField false

  showHand: ->
    @handVisible true

  illustrationHeight: ->
    viewport = LOI.adventure.interface.display.viewport()
    scale = LOI.adventure.interface.display.scale()

    # We show this context during dialogue so we only fill half the screen minus one line (8rem).
    illustrationHeight = viewport.viewportBounds.height() / scale / 2 - 8

    Math.min 240, illustrationHeight

  sceneStyle: ->
    hiddenHeight = 240 - @illustrationHeight()

    top: "-#{hiddenHeight * 0.6}rem"

  handVisibleClass: ->
    'visible' if @handVisible()
