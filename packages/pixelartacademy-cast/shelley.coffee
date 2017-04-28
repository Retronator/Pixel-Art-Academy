LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Cast.Shelley extends LOI.Adventure.Thing
  @id: -> 'PixelArtAcademy.Cast.Shelley'
  @fullName: -> "Shelley 'FBaby' Williamson"
  @shortName: -> "Shelley"
  @description: -> "It's Shelley Williamson a.k.a. FBaby. She's Retro's art agent."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.brown
    shade: LOI.Assets.Palette.Atari2600.characterShades.normal

  @initialize()
