LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Actors.Mae extends LOI.Character.Actor
  @id: -> 'PixelArtAcademy.Actors.Mae'
  @fullName: -> "Mae"
  @description: -> "It's Mae, a petite woman focused on her PixelBoy."
  @pronouns: -> LOI.Avatar.Pronouns.Feminine
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.purple
    shade: LOI.Assets.Palette.Atari2600.characterShades.darkest

  @nonPlayerCharacterDocumentUrl: -> 'retronator_pixelartacademy-actors/actors/mae.json'
  @textureUrls: -> '/pixelartacademy/actors/mae'

  @initialize()
