LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Actors.Reuben extends LOI.Character.Actor
  @id: -> 'Retronator.HQ.Actors.Reuben'
  @fullName: -> "Reuben Thiessen"
  @shortName: -> "Reuben"
  @descriptiveName: -> "![Reuben](talk to Reuben) Thiessen."
  @description: -> "It's Reuben Thiessen a.k.a. Reuben. He flew into town with his Quest Kodiak."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.blue
    shade: LOI.Assets.Palette.Atari2600.characterShades.darkest

  @nonPlayerCharacterDocumentUrl: -> 'retronator_retronator-hq/actors/reuben.json'

  @initialize()
