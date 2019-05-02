LOI = LandsOfIllusions

class LOI.Character.Part.Property.Number extends LOI.Character.Part.Property
  constructor: (@options = {}) ->
    super arguments...

    @type = 'number'

    return unless @options.dataLocation
