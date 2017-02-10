LOI = LandsOfIllusions
C0 = PixelArtAcademy.Season1.Episode0.Chapter0
RS = Retropolis.Spaceport

class C0.Start.Terrace extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter0.Start.Terrace'

  @location: -> RS.AirportTerminal.Terrace

  things: ->
    backpackState = _.nestedProperty LOI.adventure.gameState(), "things.#{C0.Start.Backpack.id()}"

    [
      C0.Start.Backpack unless backpackState?.inInventory
    ]
