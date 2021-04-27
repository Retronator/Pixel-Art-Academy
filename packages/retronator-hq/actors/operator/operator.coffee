LOI = LandsOfIllusions
HQ = Retronator.HQ

class HQ.Actors.Operator extends LOI.Adventure.Thing
  @id: -> 'Retronator.HQ.Actors.Operator'
  @fullName: -> "Henrik 'Panzer' Schumacher"
  @shortName: -> "Panzer"
  @descriptiveName: -> "Henrik '![Panzer](talk to Panzer)' Schumacher."
  @description: -> "It's Henrik 'Panzer' Schumacher, the operator of the Lands of Illusions alternate reality center."
  @pronouns: -> LOI.Avatar.Pronouns.Masculine
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.gray
    shade: LOI.Assets.Palette.Atari2600.characterShades.darkest

  @initialize()
