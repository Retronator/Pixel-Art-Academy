LOI = LandsOfIllusions
HQ = Retronator.HQ

class HQ.Actors.Operator extends LOI.Adventure.Thing
  @id: -> 'Retronator.HQ.Actors.Operator'
  @fullName: -> "Henrik 'Panzer' Schumacher"
  @shortName: -> "Panzer"
  @description: -> "It's Henrik 'Panzer' Schumacher, the operator of the Lands of Illusions alternate reality center."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.grey
    shade: LOI.Assets.Palette.Atari2600.characterShades.darkest

  @initialize()
