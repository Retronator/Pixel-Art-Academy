LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

class HQ.Actors.Corinne extends LOI.Adventure.Thing
  @id: -> 'Retronator.HQ.Actors.Corinne'
  @fullName: -> "Corinne Colgan"
  @shortName: -> "Corinne"
  @description: -> "It's Corinne Colgan, Retronator Gallery™ curator."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.aqua
    shade: LOI.Assets.Palette.Atari2600.characterShades.normal

  @initialize()
