AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.ArtStudio.Pencils extends LOI.Adventure.Context
  @id: -> 'Retronator.HQ.ArtStudio.Pencils'

  @register @id()
  template: -> @constructor.id()

  @version: -> '0.0.1'

  @initialize()

  illustrationHeight: ->
    viewport = LOI.adventure.interface.display.viewport()
    scale = LOI.adventure.interface.display.scale()

    # We show this context during dialogue so we only fill half the screen minus one line (8rem).
    illustrationHeight = viewport.viewportBounds.height() / scale / 2 - 8

    Math.min 240, illustrationHeight
