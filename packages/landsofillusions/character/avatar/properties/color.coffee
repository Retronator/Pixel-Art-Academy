LOI = LandsOfIllusions

class LOI.Character.Avatar.Properties.Color extends LOI.Character.Part.Property
  # node
  #   fields
  #     hue
  #       value
  #     shade
  #       value
  constructor: (@options = {}) ->
    super

    @type = 'color'

    return unless @options.dataLocation
