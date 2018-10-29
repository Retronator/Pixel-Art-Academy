LOI = LandsOfIllusions

class LOI.Character.Part.Property.Boolean extends LOI.Character.Part.Property
  constructor: (@options = {}) ->
    super arguments...

    @type = 'boolean'

    return unless @options.dataLocation
