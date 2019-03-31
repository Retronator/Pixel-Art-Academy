LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Actors.Ty extends LOI.Character.Actor
  @id: -> 'PixelArtAcademy.Actors.Ty'
  @fullName: -> "Ty"
  @description: -> "It's Ty, an artsy young man."
  @pronouns: -> LOI.Avatar.Pronouns.Masculine
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.orange
    shade: LOI.Assets.Palette.Atari2600.characterShades.normal

  @nonPlayerCharacterDocumentUrl: -> 'retronator_pixelartacademy-actors/actors/ty.json'
  @textureUrls: -> '/pixelartacademy/actors/ty'

  @initialize()
