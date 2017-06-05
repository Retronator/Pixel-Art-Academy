LOI = LandsOfIllusions

class LOI.Character.Part.Property.OneOf extends LOI.Character.Part.Property
  constructor: (@options = {}) ->
    super
    
    @type = 'oneOf'

    return unless @options.dataField
