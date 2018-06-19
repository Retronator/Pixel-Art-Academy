LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

class HQ.Actors.Alexandra extends LOI.Adventure.Thing
  @id: -> 'Retronator.HQ.Actors.Alexandra'
  @fullName: -> "Alexandra Hood"
  @shortName: -> "Alexandra"
  @description: -> "It's Alexandra Hood, resident artist and coffee drinker at Retronator."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.red
    shade: LOI.Assets.Palette.Atari2600.characterShades.darker

  @initialize()
