LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Items.Bottle.Scene extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Items.Bottle.Scene'
  @location: -> LOI.Adventure.Inventory
  @timelineId: -> [PAA.TimelineIds.DareToDream, LOI.TimelineIds.Present]

  @initialize()

  things: ->
    bottles = PAA.Items.Bottle.getCopies timelineId: LOI.adventure.currentTimelineId()

    _.filter bottles, (bottle) -> bottle.state 'inInventory'
