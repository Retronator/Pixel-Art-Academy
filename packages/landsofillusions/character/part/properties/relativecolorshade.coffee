LOI = LandsOfIllusions

class LOI.Character.Part.Property.RelativeColorShade extends LOI.Character.Part.Property
  constructor: (@options = {}) ->
    super

    return unless @options.dataField
