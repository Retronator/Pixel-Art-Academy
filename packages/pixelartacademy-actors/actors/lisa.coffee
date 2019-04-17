LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Actors.Lisa extends LOI.Character.Actor
  @id: -> 'PixelArtAcademy.Actors.Lisa'
  @fullName: -> "Lisa"
  @description: -> "It's Lisa, an outgoing, friendly student."
  @pronouns: -> LOI.Avatar.Pronouns.Feminine
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.magenta
    shade: LOI.Assets.Palette.Atari2600.characterShades.lighter

  @nonPlayerCharacterDocumentUrl: -> 'retronator_pixelartacademy-actors/actors/lisa.json'
  @textureUrls: -> '/pixelartacademy/actors/lisa'

  @initialize()

  constructor: ->
    super arguments...

    @require PAA.Student
