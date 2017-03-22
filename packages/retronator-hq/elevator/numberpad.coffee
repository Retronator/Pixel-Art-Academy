LOI = LandsOfIllusions
HQ = Retronator.HQ

class HQ.Elevator.NumberPad extends LOI.Adventure.Thing
  @id: -> 'Retronator.HQ.Elevator.NumberPad'
  @fullName: -> "number pad"
  @shortName: -> "pad"
  @description: -> "It's the pad that controls the elevator."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.yellow
    shade: LOI.Assets.Palette.Atari2600.characterShades.lightest

  @initialize()
