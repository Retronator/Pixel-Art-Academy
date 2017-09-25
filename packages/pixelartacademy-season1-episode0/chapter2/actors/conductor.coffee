LOI = LandsOfIllusions
PAA = PixelArtAcademy
C2 = PixelArtAcademy.Season1.Episode0.Chapter2

class C2.Actors.Conductor extends LOI.Adventure.Thing
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter2.Actors.Conductor'
  @fullName: -> "conductor"
  @description: -> "It's the train conductor. You could tell that by the vest and the tie, but mostly by the Caltrain badge."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.red
    shade: LOI.Assets.Palette.Atari2600.characterShades.normal

  @initialize()
