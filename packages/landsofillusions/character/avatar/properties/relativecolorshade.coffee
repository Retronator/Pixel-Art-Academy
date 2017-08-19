LOI = LandsOfIllusions

class LOI.Character.Avatar.Properties.RelativeColorShade extends LOI.Character.Part.Property
  constructor: (@options = {}) ->
    super

    @type = 'relativeColorShade'

    return unless @options.dataLocation
