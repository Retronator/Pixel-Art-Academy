LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Adventure extends LOI.Adventure
  @register 'PixelArtAcademy.Adventure'

  constructor: ->
    super

  onCreated: ->
    @items =
      pixelBoy: new PAA.PixelBoy @

    studio = new PAA.Adventure.Locations.Studio
    dorm = new PAA.Adventure.Locations.Dorm

    super

    @currentLocation studio
