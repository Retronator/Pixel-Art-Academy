LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Actors.Jaxx extends LOI.Character.Actor
  @id: -> 'PixelArtAcademy.Actors.Jaxx'
  @fullName: -> "Jaxx"
  @description: -> "It's Jaxx, a crafty asian young adult."
  @pronouns: -> @constructor.Pronouns.Neutral
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.red
    shade: LOI.Assets.Palette.Atari2600.characterShades.darkest

  @nonPlayerCharacterDocumentUrl: -> 'retronator_pixelartacademy-actors/actors/jaxx.json'
  @textureUrls: -> '/pixelartacademy/actors/jaxx'

  @initialize()
