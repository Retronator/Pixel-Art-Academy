LOI = LandsOfIllusions

class LOI.Character.Part.Property.OneOf extends LOI.Character.Part.Property
  constructor: (@options = {}) ->
    super

    @type = 'oneOf'

    return unless @options.dataLocation

    # One-of properties simply hold a part of the given type.
    @part = LOI.Character.Part.Types[@options.type].create
      dataLocation: @options.dataLocation
