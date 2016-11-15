LOI = LandsOfIllusions
HQ = Retronator.HQ

class HQ.Locations.Elevator.NumberPad extends LOI.Adventure.Thing
  @id: -> 'Retronator.HQ.Locations.Elevator.NumberPad'
  @fullName: -> "number pad"
  @shortName: -> "pad"
  @description: -> "It's the pad that controls the elevator."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.yellow
    shade: LOI.Assets.Palette.Atari2600.characterShades.lightest

  @initialize()
