LOI = LandsOfIllusions
HQ = Retronator.HQ

class HQ.Actors.ElevatorNumberPad extends LOI.Adventure.Actor
  @options =
    avatar:
      id: 'Retronator.HQ.Actors.ElevatorNumberPad'
      fullName: "number pad"
      shortName: "pad"
      description: "It's the pad that controls the elevator."
      color:
        hue: LOI.Assets.Palette.Atari2600.hues.yellow
        shade: LOI.Assets.Palette.Atari2600.characterShades.lightest

  @initialize @options

  constructor: ->
    # Construct an actor with predefined options.
    super @constructor.options
