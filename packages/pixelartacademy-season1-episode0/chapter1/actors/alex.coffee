LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode0.Chapter1

class C1.Actors.Alex extends LOI.Adventure.Thing
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Actors.Alex'
  @fullName: -> "Alex"
  @description: -> "It's your friend Alex, but you can't really remember how you know each other."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.magenta
    shade: LOI.Assets.Palette.Atari2600.characterShades.darker

  @initialize()
