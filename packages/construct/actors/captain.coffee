LOI = LandsOfIllusions
HQ = Retronator.HQ

class LOI.Construct.Actors.Captain extends LOI.Adventure.Thing
  @id: -> 'LandsOfIllusionsConstruct.Actors.Captain'
  @fullName: -> "Gordon 'Captain' Morgan"
  @shortName: -> "Captain"
  @description: -> "It's the Captain, Gordon Morgan. He takes care of the Construct."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.purple
    shade: LOI.Assets.Palette.Atari2600.characterShades.darkest

  @initialize()
