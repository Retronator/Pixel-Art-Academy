LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Actors.Alexandra extends LOI.Adventure.Thing
  @id: -> 'Retronator.HQ.Actors.Alexandra'
  @fullName: -> "Alexandra Hood"
  @shortName: -> "Alexandra"
  @descriptiveName: -> "![Alexandra](talk to Alexandra) Hood."
  @description: -> "It's Alexandra Hood, resident artist and coffee drinker at Retronator."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.olive
    shade: LOI.Assets.Palette.Atari2600.characterShades.darker

  @initialize()
