LOI = LandsOfIllusions

class LOI.Character.Part.Property.OneOf extends LOI.Character.Part.Property
  constructor: (@options = {}) ->
    super

    return unless @options.dataField
