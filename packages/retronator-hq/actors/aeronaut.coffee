LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

class HQ.Actors.Aeronaut extends LOI.Adventure.Thing
  @id: -> 'Retronator.HQ.Actors.Aeronaut'
  @fullName: -> "Reuben 'Aeronaut' Thiessen"
  @shortName: -> "Reuben"
  @description: -> "It's Reuben Thiessen a.k.a. Aeronaut. He flew into town with his Cessna 182 Skylane."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.blue
    shade: LOI.Assets.Palette.Atari2600.characterShades.lighter

  @initialize()
