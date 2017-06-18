LOI = LandsOfIllusions

class LOI.Character.Part.Property.String extends LOI.Character.Part.Property
  constructor: (@options = {}) ->
    super

    @type = 'string'

    return unless @options.dataLocation
