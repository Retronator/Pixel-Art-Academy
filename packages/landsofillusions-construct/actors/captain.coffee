LOI = LandsOfIllusions

class LOI.Construct.Actors.Captain extends LOI.Adventure.Thing
  @id: -> 'LandsOfIllusions.Construct.Actors.Captain'
  @fullName: -> "Gordon 'Captain' Morgan"
  @shortName: -> "Captain"
  @description: -> "It's the Captain, Gordon Morgan. He manages the Loader."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.purple
    shade: LOI.Assets.Palette.Atari2600.characterShades.darkest

  @initialize()
