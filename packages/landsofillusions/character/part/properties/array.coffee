LOI = LandsOfIllusions

class LOI.Character.Part.Property.Array extends LOI.Character.Part.Property
  constructor: (@options = {}) ->
    super
    
    return unless @options.dataField
