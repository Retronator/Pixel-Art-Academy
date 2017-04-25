LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Cast.Shelley extends LOI.Adventure.Thing
  @id: -> 'PixelArtAcademy.Cast.Shelley'
  @fullName: -> "Shelley Williamson"
  @shortName: -> "Shelley"
  @description: -> "It's Shelley Williamson, Retro's art dealer."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.brown
    shade: LOI.Assets.Palette.Atari2600.characterShades.normal

  @initialize()
