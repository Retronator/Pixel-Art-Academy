LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Actors.Jaxx extends LOI.Character.Actor
  @id: -> 'PixelArtAcademy.Actors.Jaxx'
  @fullName: -> "Jaxx"
  @description: -> "It's Jaxx, a crafty asian young adult."
  @pronouns: -> LOI.Avatar.Pronouns.Neutral
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.red
    shade: LOI.Assets.Palette.Atari2600.characterShades.darkest

  @assetUrls: -> '/pixelartacademy/actors/jaxx'

  @initialize()

  constructor: ->
    super arguments...

    @require PAA.Student
