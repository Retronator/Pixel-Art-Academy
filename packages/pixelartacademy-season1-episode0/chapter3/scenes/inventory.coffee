LOI = LandsOfIllusions
PAA = PixelArtAcademy
C3 = PixelArtAcademy.Season1.Episode0.Chapter3
HQ = Retronator.HQ

class C3.Inventory extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter3.Inventory'

  @location: -> LOI.Adventure.Inventory
  @timelineId: -> LOI.TimelineIds.Construct

  @initialize()

  constructor: ->
    super

  things: ->
    [
      HQ.Items.OperatorLink
      LOI.Items.Sync
    ]
