LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Cast.Retro extends LOI.Adventure.Actor
  @options =
    avatar:
      id: 'PixelArtAcademy.Cast.Retro'
      fullName: "Matej 'Retro' Jan"
      shortName: "Retro"
      description: "It's Matej Jan a.k.a. Retro. He's the man behind Retronator and the developer of Pixel Art Academy."
      color:
        hue: LOI.Assets.Palette.Atari2600.hues.red
        shade: LOI.Assets.Palette.Atari2600.characterShades.normal

  @initialize @options

  constructor: ->
    # Construct an actor with predefined options.
    super @constructor.options
