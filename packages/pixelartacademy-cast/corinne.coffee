LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Cast.Corinne extends LOI.Adventure.Thing
  @id: -> 'PixelArtAcademy.Cast.Corinne'
  @fullName: -> "Corinne 'Coco' Colgan"
  @shortName: -> "Corinne"
  @description: -> "It's Corinne Colgan a.k.a. Coco, Retronator gallery adviser."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.aqua
    shade: LOI.Assets.Palette.Atari2600.characterShades.normal

  @initialize()
