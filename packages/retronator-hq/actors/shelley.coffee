LOI = LandsOfIllusions
HQ = Retronator.HQ

class HQ.Actors.Shelley extends LOI.Character.Actor
  @id: -> 'Retronator.HQ.Actors.Shelley'
  @fullName: -> "Shelley Williamson"
  @shortName: -> "Shelley"
  @descriptiveName: -> "![Shelley](talk to Shelley) Williamson."
  @description: -> "It's Shelley Williamson, Retro's art dealer."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.brown
    shade: LOI.Assets.Palette.Atari2600.characterShades.normal

  @nonPlayerCharacterDocumentUrl: -> 'retronator_retronator-hq/actors/shelley.json'

  @initialize()
