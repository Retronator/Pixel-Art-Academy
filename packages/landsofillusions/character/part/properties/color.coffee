LOI = LandsOfIllusions

class LOI.Character.Part.Property.Color extends LOI.Character.Part.Property
  constructor: (@options = {}) ->
    super

    @type = 'color'

    return unless @options.dataField
