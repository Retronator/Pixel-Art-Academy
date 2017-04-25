LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Cast.CoCo extends LOI.Adventure.Thing
  @id: -> 'PixelArtAcademy.Cast.CoCo'
  @fullName: -> "Corinne 'CoCo' Colgan"
  @shortName: -> "Corinne"
  @description: -> "It's Corinne Colgan a.k.a. CoCo, Retronator Gallery™ curator."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.aqua
    shade: LOI.Assets.Palette.Atari2600.characterShades.normal

  @initialize()
