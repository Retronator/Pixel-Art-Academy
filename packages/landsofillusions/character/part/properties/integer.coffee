LOI = LandsOfIllusions

class LOI.Character.Part.Property.Integer extends LOI.Character.Part.Property
  constructor: (@options = {}) ->
    super arguments...

    @type = 'integer'

    return unless @options.dataLocation
