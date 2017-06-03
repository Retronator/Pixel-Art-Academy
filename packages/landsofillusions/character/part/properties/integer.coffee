LOI = LandsOfIllusions

class LOI.Character.Part.Property.Integer extends LOI.Character.Part.Property
  constructor: (@options = {}) ->
    super

    return unless @options.dataField
