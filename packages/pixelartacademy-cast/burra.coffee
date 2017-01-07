LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Cast.Burra extends LOI.Adventure.Thing
  @id: -> 'PixelArtAcademy.Cast.Burra'
  @fullName: -> "Sarah 'Burra' Burrough"
  @shortName: -> "Burra"
  @description: -> "It's Sarah Burrough a.k.a. Burra. She's doing outreach for Pixel Art Academy."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.green
    shade: LOI.Assets.Palette.Atari2600.characterShades.darkest

  @initialize()
