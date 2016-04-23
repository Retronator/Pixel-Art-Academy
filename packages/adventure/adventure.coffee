LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Adventure extends LOI.Adventure
  @register 'PixelArtAcademy.Adventure'

  constructor: ->
    super

  onCreated: ->
    @items =
      pixelBoy: new PAA.PixelBoy @

    @locations =
      dorm: new PAA.Adventure.Locations.Dorm

    @startLocation = @locations.dorm

    super
