LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

class HQ.Actors.Burra extends LOI.Adventure.Thing
  @id: -> 'Retronator.HQ.Actors.Burra'
  @fullName: -> "Sarah 'Burra' Burrough"
  @shortName: -> "Burra"
  @description: -> "It's Sarah Burrough a.k.a. Burra. She's doing outreach for Pixel Art Academy."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.green
    shade: LOI.Assets.Palette.Atari2600.characterShades.darkest

  @initialize()
