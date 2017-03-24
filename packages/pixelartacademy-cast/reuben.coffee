LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Cast.Reuben extends LOI.Adventure.Thing
  @id: -> 'PixelArtAcademy.Cast.Reuben'
  @fullName: -> "Reuben 'Aeronaut' Thiessen"
  @shortName: -> "Reuben"
  @description: -> "It's Reuben Thiessen a.k.a. Aeronaut. He flew into town with his Cessna 182 Skylane."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.blue
    shade: LOI.Assets.Palette.Atari2600.characterShades.lighter

  @initialize()
