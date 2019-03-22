LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Actors.Saanvi extends LOI.Character.Actor
  @id: -> 'PixelArtAcademy.Actors.Saanvi'
  @fullName: -> "Saanvi"
  @description: -> "It's Saanvi, a charismatic woman with a witty smile."
  @pronouns: -> @constructor.Pronouns.Feminine
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.lime
    shade: LOI.Assets.Palette.Atari2600.characterShades.darkest

  @nonPlayerCharacterDocumentUrl: -> 'retronator_pixelartacademy-actors/actors/saanvi.json'
  @textureUrls: -> '/pixelartacademy/actors/saanvi'

  @initialize()
